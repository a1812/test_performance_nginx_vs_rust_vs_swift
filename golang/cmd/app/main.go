package main

import (
	"math/rand"
	"strconv"

	"github.com/valyala/fasthttp"
)

func main() {
	handler := func(ctx *fasthttp.RequestCtx) {
		if string(ctx.Path()) != "/" {
			ctx.SetStatusCode(fasthttp.StatusNotFound)
			return
		}

		randomID := rand.Intn(1_000_000) + 1

		ctx.SetContentType("application/json")
		ctx.WriteString(`{"id":`)
		ctx.WriteString(strconv.Itoa(randomID))
		ctx.WriteString(`,"name":"User_`)
		ctx.WriteString(strconv.Itoa(randomID))
		ctx.WriteString(`","email":"dev_`)
		ctx.WriteString(strconv.Itoa(randomID))
		ctx.WriteString(`@apple.com","roles":[`)

		if randomID%2 == 0 {
			ctx.WriteString(`"admin"`)
		} else {
			ctx.WriteString(`"user"`)
		}

		ctx.WriteString(`],"isActive":`)
		if randomID%3 == 0 {
			ctx.WriteString(`true`)
		} else {
			ctx.WriteString(`false`)
		}
		ctx.WriteString(`}`)
	}

	fasthttp.ListenAndServe(":2999", handler)
}
