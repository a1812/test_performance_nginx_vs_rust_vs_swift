import NIOPosix
import NIOHTTP1
import NIOCore
import Foundation

// 1. Модель данных. Swift 6 автоматически делает её Sendable.
struct UserProfile: Codable {
    let id: Int
    let name: String
    let email: String
    let roles: [String]
    let isActive: Bool
}

// 2. Предварительно создаем JSON-энкодер
// В реальном Corpo-приложении мы инстанцируем его один раз
private let encoder = JSONEncoder()

final class WorkHandler: ChannelInboundHandler, @unchecked Sendable {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let part = self.unwrapInboundIn(data)

        if case .head = part {
            let randomId = Int.random(in: 1...1_000_000)
            let user = UserProfile(
                id: randomId,
                name: "User_\(randomId)", // Динамическая строка
                email: "dev_\(randomId)@apple.com",
                roles: randomId % 2 == 0 ? ["admin"] : ["user"],
                isActive: randomId % 3 == 0
            )
            

            do {
                // Генерируем JSON (нагрузка на CPU и аллокации памяти)
                let jsonData = try encoder.encode(user)
                
                var headers = HTTPHeaders()
                headers.add(name: "Content-Type", value: "application/json")
                headers.add(name: "Content-Length", value: "\(jsonData.count)")
                headers.add(name: "Connection", value: "keep-alive")

                let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok, headers: headers)
                context.write(self.wrapOutboundOut(.head(head)), promise: nil)

                var buffer = context.channel.allocator.buffer(capacity: jsonData.count)
                buffer.writeBytes(jsonData)
                context.write(self.wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)

                context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
            } catch {
                // Обработка ошибок (в бенчмарке не должна срабатывать)
                context.close(promise: nil)
            }
        }
    }
}

// 2. Настройка системы (Thread-per-Core)
let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

let bootstrap = ServerBootstrap(group: group)
    .serverChannelOption(ChannelOptions.backlog, value: 256)
    .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
    .childChannelInitializer { channel in
        // Добавляем HTTP парсер и наш воркер в конвейер (pipeline)
        channel.pipeline.configureHTTPServerPipeline().flatMap {
            channel.pipeline.addHandler(WorkHandler())
        }
    }
    .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
    .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)

// 3. Запуск
let host = "0.0.0.0"
let port = 3001
let channel = try bootstrap.bind(host: host, port: port).wait()

print("Server started on \(host):\(port). Threads: \(System.coreCount)")
try channel.closeFuture.wait()
