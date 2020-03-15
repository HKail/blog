package control

import (
	"fmt"
	"github.com/gin-gonic/gin"
	. "github.com/hkail/blog/conf"
	"github.com/hkail/blog/model"
	"net/http"
	"strconv"
	"strings"
)

func IndexView(c *gin.Context) {
	page, err := strconv.Atoi(c.DefaultQuery("p", "1"))
	if err != nil {
		page = 1
	}
	posts, _ := model.PostGetPage(page, Conf.SysConf.PageSize)
	nm := make(map[string]string)
	if page > 1 {
		nm["pp"] = fmt.Sprintf("/?p=%d", page-1)
	}
	if count, _ := model.PostCount(); count > page*Conf.SysConf.PageSize {
		nm["np"] = fmt.Sprintf("/?p=%d", page+1)
	}
	c.HTML(http.StatusOK, "index.html", gin.H{
		"posts": posts,
		"nm":    nm,
	})
}

func ArchiveView(c *gin.Context) {
	archives := model.PostGetArchives()
	c.HTML(http.StatusOK, "archive.html", gin.H{
		"archives": archives,
	})
}

func TagsView(c *gin.Context) {
	postTags := model.PostTagCountGroupByTid()
	c.HTML(http.StatusOK, "tags.html", gin.H{
		"postTags": postTags,
	})
}

func TagPostView(c *gin.Context) {
	tv := c.Param("tv")
	tag := model.TagGetByValue(tv)
	page, err := strconv.Atoi(c.DefaultQuery("p", "1"))
	if err != nil {
		page = 1
	}
	posts := model.PostGetPageByTid(tag.ID, page, Conf.SysConf.PageSize)
	nm := make(map[string]string)
	if page > 1 {
		nm["pp"] = fmt.Sprintf("/tag/%s?p=%d", tv, page-1)
	}
	if count := model.PostCountByTid(tag.ID); count > page*Conf.SysConf.PageSize {
		nm["np"] = fmt.Sprintf("/tag/%s?p=%d", tv, page+1)
	}
	c.HTML(http.StatusOK, "tag-post.html", gin.H{
		"posts": posts,
		"tag":   tag,
		"nm":    nm,
	})
}

func PostView(c *gin.Context) {
	path := c.Param("path")
	if strings.Contains(path, ".html") {
		path = path[:len(path)-5]
	}
	post := model.PostGetByPath(path)
	nm := model.PostGetNavMap(post)
	c.HTML(http.StatusOK, "post.html", gin.H{
		"post": post,
		"nm":   nm,
	})
}
