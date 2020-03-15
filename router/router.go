package router

import (
	"github.com/gin-gonic/gin"
	"github.com/hkail/blog/control"
	"github.com/hkail/blog/util"
	"html/template"
)

var R *gin.Engine

func init() {
	R = gin.Default()

	R.SetFuncMap(template.FuncMap{
		"format":   util.TimeFormat,
		"str2html": util.Str2HTML,
	})

	R.Static("/static", "./static")
	R.LoadHTMLGlob("views/*")

	R.GET("/", control.IndexView)
	R.GET("/archives", control.ArchiveView)
	R.GET("/tags", control.TagsView)
	R.GET("/tag/:tv", control.TagPostView)
	R.GET("/post/:path", control.PostView)
}
