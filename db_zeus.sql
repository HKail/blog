/*
 Navicat Premium Data Transfer

 Source Server         : mysql-local
 Source Server Type    : MySQL
 Source Server Version : 50729
 Source Host           : localhost:3306
 Source Schema         : db_zeus

 Target Server Type    : MySQL
 Target Server Version : 50729
 File Encoding         : 65001

 Date: 15/03/2020 20:36:48
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for blog_post_tags
-- ----------------------------
DROP TABLE IF EXISTS `blog_post_tags`;
CREATE TABLE `blog_post_tags`  (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID，自增主键',
  `post_id` int(11) UNSIGNED NOT NULL COMMENT '外键，文章表ID',
  `tag_id` int(11) UNSIGNED NOT NULL COMMENT '外键，标签表ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '文章标签关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of blog_post_tags
-- ----------------------------
INSERT INTO `blog_post_tags` VALUES (1, 1, 1);
INSERT INTO `blog_post_tags` VALUES (2, 2, 1);
INSERT INTO `blog_post_tags` VALUES (3, 2, 2);
INSERT INTO `blog_post_tags` VALUES (4, 3, 2);
INSERT INTO `blog_post_tags` VALUES (5, 4, 1);
INSERT INTO `blog_post_tags` VALUES (6, 4, 2);
INSERT INTO `blog_post_tags` VALUES (7, 5, 1);
INSERT INTO `blog_post_tags` VALUES (8, 5, 2);
INSERT INTO `blog_post_tags` VALUES (9, 6, 1);
INSERT INTO `blog_post_tags` VALUES (10, 7, 1);
INSERT INTO `blog_post_tags` VALUES (11, 8, 1);
INSERT INTO `blog_post_tags` VALUES (12, 9, 1);
INSERT INTO `blog_post_tags` VALUES (13, 10, 1);
INSERT INTO `blog_post_tags` VALUES (14, 11, 1);

-- ----------------------------
-- Table structure for blog_posts
-- ----------------------------
DROP TABLE IF EXISTS `blog_posts`;
CREATE TABLE `blog_posts`  (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID，自增主键',
  `author` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '作者',
  `title` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标题',
  `path` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '路径',
  `des` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '描述',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '内容',
  `draft` tinyint(4) UNSIGNED NOT NULL DEFAULT 1 COMMENT '草稿，0：否，1：是',
  `published_at` timestamp(0) NULL DEFAULT NULL COMMENT '发布时间',
  `created_at` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `deleted_at` timestamp(0) NULL DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '博客文章表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of blog_posts
-- ----------------------------
INSERT INTO `blog_posts` VALUES (1, 'Cole Lie', 'Go Map 源码分析', 'go-map-resource', 'Go 源码解读和学习', '# Go Map 源码分析', 0, '2020-02-06 13:49:20', '2020-04-01 13:49:26', '2020-03-13 13:49:29', NULL);
INSERT INTO `blog_posts` VALUES (2, 'Cole Lie', 'Gin 源码学习（一）丨请求中 URL 的参数是如何解析的？', 'gin-how-parsing-request-url-parameter', 'Gin 是如何解析请求中的URL参数的', '# Gin 源码学习（一）丨请求中 URL 的参数是如何解析的？\n\n> If you need performance and good productivity, you will love Gin.\n\n这是 Gin 源码学习的第一篇，为什么是 Gin 呢？\n\n正如 Gin 官方文档中所说，Gin 是一个注重性能和生产的 web 框架，并且号称其性能要比 httprouter 快近40倍，这是选择 Gin 作为源码学习的理由之一，因为其注重性能；其次是 Go 自带函数库中的 `net` 库和 `context` 库，如果要说为什么 Go 能在国内这么火热，那么原因肯定和 `net` 库和 `context` 库有关，所以本系列的文章将借由 `net` 库和 `context` 库在 Gin 中的运用，顺势对这两个库进行讲解。\n\n本系列的文章将由浅入深，从简单到复杂，在讲解 Gin 源代码的过程中结合 Go 自带函数库，对 Go 自带函数库中某些巧妙设计进行讲解。\n\n下面开始 Gin 源码学习的第一篇：请求中 URL 的参数是如何解析的？\n\n## 目录\n\n- [路径中的参数解析](#路径中的参数解析)\n- [查询字符串的参数解析](#查询字符串的参数解析)\n- [总结](#总结)\n\n### 路径中的参数解析\n\n```go\nfunc main() {\n	router := gin.Default()\n\n	router.GET(\"/user/:name/*action\", func(c *gin.Context) {\n		name := c.Param(\"name\")\n		action := c.Param(\"action\")\n		c.String(http.StatusOK, \"%s is %s\", name, action)\n	})\n\n	router.Run(\":8000\")\n}\n```\n\n引用 Gin 官方文档中的一个例子，我们把关注点放在 `c.Param(key)` 函数上面。\n\n当发起 URI 为 /user/cole/send 的 GET 请求时，得到的响应体如下：\n\n```\ncole is /send\n```\n\n而发起 URI 为 /user/cole/ 的 GET 请求时，得到的响应体如下：\n\n```\ncole is /\n```\n\n在 Gin 内部，是如何处理做到的呢？我们先来观察 `gin.Context` 的内部函数 `Param()`，其源代码如下：\n\n```go\n// Param returns the value of the URL param.\n// It is a shortcut for c.Params.ByName(key)\n//     router.GET(\"/user/:id\", func(c *gin.Context) {\n//         // a GET request to /user/john\n//         id := c.Param(\"id\") // id == \"john\"\n//     })\nfunc (c *Context) Param(key string) string {\n	return c.Params.ByName(key)\n}\n```\n\n从源代码的注释中可以知道，`c.Param(key)` 函数实际上只是 `c.Params.ByName()` 函数的一个捷径，那么我们再来观察一下 `c.Params` 属性及其类型究竟是何方神圣，其源代码如下：\n\n```go\n// Context is the most important part of gin. It allows us to pass variables between middleware,\n// manage the flow, validate the JSON of a request and render a JSON response for example.\ntype Context struct {\n	Params Params\n}\n\n// Param is a single URL parameter, consisting of a key and a value.\ntype Param struct {\n	Key   string\n	Value string\n}\n\n// Params is a Param-slice, as returned by the router.\n// The slice is ordered, the first URL parameter is also the first slice value.\n// It is therefore safe to read values by the index.\ntype Params []Param\n```\n\n首先，`Params` 是 `gin.Context` 类型中的一个参数（上面源代码中省略部分属性），`gin.Context` 是 Gin 中最重要的部分，其作用类似于 Go 自带库中的 `context` 库，在本系列后续的文章中会分别对各自进行讲解。\n\n接着，`Params` 类型是一个由 `router` 返回的 `Param` 切片，同时，该切片是有序的，第一个 URL 参数也是切片的第一个值，而 `Param` 类型是由 `Key` 和 `Value` 组成的，用于表示 URL 中的参数。\n\n所以，上面获取 URL 中的 `name` 参数和 `action` 参数，也可以使用以下方式获取：\n\n```go\nname := c.Params[0].Value\naction := c.Params[1].Value\n```\n\n而这些并不是我们所关心的，我们想知道的问题是 Gin 内部是如何把 URL 中的参数给传递到 `c.Params` 中的？先看以下下方的这段代码：\n\n```go\nfunc main() {\n	router := gin.Default()\n\n	router.GET(\"/aa\", func(c *gin.Context) {})\n	router.GET(\"/bb\", func(c *gin.Context) {})\n	router.GET(\"/u\", func(c *gin.Context) {})\n	router.GET(\"/up\", func(c *gin.Context) {})\n\n	router.POST(\"/cc\", func(c *gin.Context) {})\n	router.POST(\"/dd\", func(c *gin.Context) {})\n	router.POST(\"/e\", func(c *gin.Context) {})\n	router.POST(\"/ep\", func(c *gin.Context) {})\n\n	// http://127.0.0.1:8000/user/cole/send => cole is /send\n	// http://127.0.0.1:8000/user/cole/ => cole is /\n	router.GET(\"/user/:name/*action\", func(c *gin.Context) {\n		// name := c.Param(\"name\")\n		// action := c.Param(\"action\")\n\n		name := c.Params[0].Value\n		action := c.Params[1].Value\n		c.String(http.StatusOK, \"%s is %s\", name, action)\n	})\n\n	router.Run(\":8000\")\n}\n```\n\n把关注点放在路由的绑定上，这段代码保留了最开始的那个 GET 路由，并且另外创建了 4 个 GET 路由和 4 个 POST 路由，在 Gin 内部，将会生成类似下图所示的路由树。\n\n![1.jpg](http://127.0.0.1:8000/static/49564c17d66723f31120eef2914ca05a.jpg)\n\n当然，请求 URL 是如何匹配的问题也不是本文要关注的，在后续的文章中将会对其进行详细讲解，在这里，我们需要关注的是节点中 `wildChild` 属性值为 `true` 的节点。结合上图，看一下下面的代码（为了突出重点，省略部分源代码）：\n\n```go\nfunc (engine *Engine) handleHTTPRequest(c *Context) {\n	httpMethod := c.Request.Method\n	rPath := c.Request.URL.Path\n    unescape := false\n    ...\n    ...\n\n	// Find root of the tree for the given HTTP method\n	t := engine.trees\n	for i, tl := 0, len(t); i < tl; i++ {\n		if t[i].method != httpMethod {\n			continue\n		}\n		root := t[i].root\n		// Find route in tree\n		value := root.getValue(rPath, c.Params, unescape)\n		if value.handlers != nil {\n			c.handlers = value.handlers\n			c.Params = value.params\n			c.fullPath = value.fullPath\n			c.Next()\n			c.writermem.WriteHeaderNow()\n			return\n		}\n        ...\n        ...\n	}\n    ...\n    ...\n}\n```\n\n首先，是获取请求的方法以及请求的 URL 路径，以上述的 `http://127.0.0.1:8000/user/cole/send` 请求为例，`httpMethod` 和 `rPath` 分别为 `GET` 和 `/user/cole/send`。\n\n然后，使用 `engine.trees` 获取路由树切片（如上路由树图的最上方），并通过 for 循环遍历该切片，找到类型与 `httpMethod` 相同的路由树的根节点。\n\n最后，调用根节点的 `getValue(path, po, unescape)` 函数，返回一个 `nodeValue` 类型的对象，将该对象中的 `params` 属性值赋给 `c.Params`。\n\n好了，我们的关注点，已经转移到了 `getValue(path, po, unescape)` 函数，`unescape` 参数用于标记是否转义处理，在这里先将其忽略，下面源代码展示了在 `getValue(path, po, unescape)` 函数中解析 URL 参数的过程，同样地，只保留了与本文内容相关的源代码：\n\n```go\nfunc (n *node) getValue(path string, po Params, unescape bool) (value nodeValue) {\n	value.params = po\nwalk: // Outer loop for walking the tree\n	for {\n		if len(path) > len(n.path) {\n			if path[:len(n.path)] == n.path {\n				path = path[len(n.path):]\n				// 从根往下匹配, 找到节点中wildChild属性为true的节点\n				if !n.wildChild {\n					c := path[0]\n					for i := 0; i < len(n.indices); i++ {\n						if c == n.indices[i] {\n							n = n.children[i]\n							continue walk\n						}\n					}\n\n					...\n					...\n					return\n				}\n\n				// handle wildcard child\n				n = n.children[0]\n				// 匹配两种节点类型: param和catchAll\n				// 可简单理解为:\n				// 节点的path值为\':xxx\', 则节点为param类型节点\n				// 节点的path值为\'/*xxx\', 则节点为catchAll类型节点\n				switch n.nType {\n				case param:\n					// find param end (either \'/\' or path end)\n					end := 0\n					for end < len(path) && path[end] != \'/\' {\n						end++\n					}\n\n					// save param value\n					if cap(value.params) < int(n.maxParams) {\n						value.params = make(Params, 0, n.maxParams)\n					}\n					i := len(value.params)\n					value.params = value.params[:i+1] // expand slice within preallocated capacity\n					value.params[i].Key = n.path[1:]\n					val := path[:end]\n					if unescape {\n						var err error\n						if value.params[i].Value, err = url.QueryUnescape(val); err != nil {\n							value.params[i].Value = val // fallback, in case of error\n						}\n					} else {\n						value.params[i].Value = val\n					}\n\n					// we need to go deeper!\n					if end < len(path) {\n						if len(n.children) > 0 {\n							path = path[end:]\n							n = n.children[0]\n							continue walk\n						}\n\n						...\n						return\n					}\n					...\n					...\n					return\n\n				case catchAll:\n					// save param value\n					if cap(value.params) < int(n.maxParams) {\n						value.params = make(Params, 0, n.maxParams)\n					}\n					i := len(value.params)\n					value.params = value.params[:i+1] // expand slice within preallocated capacity\n					value.params[i].Key = n.path[2:]\n					if unescape {\n						var err error\n						if value.params[i].Value, err = url.QueryUnescape(path); err != nil {\n							value.params[i].Value = path // fallback, in case of error\n						}\n					} else {\n						value.params[i].Value = path\n					}\n					return\n\n				default:\n					panic(\"invalid node type\")\n				}\n			}\n		}\n		...\n		...\n		return\n	}\n}\n```\n\n首先，会通过 `path` 在路由树中进行匹配，找到节点中 `wildChild` 值为 `true` 的节点，表示该节点的孩子节点为通配符节点，然后获取该节点的孩子节点。\n\n然后，通过 switch 判断该通配符节点的类型，若为 `param`，则进行截取，获取参数的 Key 和 Value，并放入 `value.params` 中；若为 `catchAll`，则无需截取，直接获取参数的 Key 和 Value，放入 `value.params` 中即可。其中 `n.maxParams` 属性在创建路由时赋值，也不是这里需要关注的内容，在本系列的后续文章中讲会涉及。\n\n上述代码中，比较绕的部分主要为节点的匹配，可结合上面给出的路由树图观看，方便理解，同时，也省略了部分与我们目的无关的源代码，相信要看懂上述给出的源代码，应该并不困难。\n\n### 查询字符串的参数解析\n\n```go\nfunc main() {\n	router := gin.Default()\n\n	// http://127.0.0.1:8000/welcome?firstname=Les&lastname=An => Hello Les An\n	router.GET(\"/welcome\", func(c *gin.Context) {\n		firstname := c.DefaultQuery(\"firstname\", \"Guest\")\n		lastname := c.Query(\"lastname\") // shortcut for c.Request.URL.Query().Get(\"lastname\")\n\n		c.String(http.StatusOK, \"Hello %s %s\", firstname, lastname)\n	})\n	router.Run(\":8080\")\n}\n```\n\n同样地，引用 Gin 官方文档中的例子，我们把关注点放在 `c.DefaultQuery(key, defaultValue)` 和 `c.Query(key)` 上，当然，这俩其实没啥区别。\n\n当发起 URI 为 /welcome?firstname=Les&lastname=An 的 GET 请求时，得到的响应体结果如下：\n\n```\nHello Les An\n```\n\n接下来，看一下 `c.DefaultQuery(key, defaultValue)` 和 `c.Query(key)` 的源代码：\n\n```go\n// Query returns the keyed url query value if it exists,\n// otherwise it returns an empty string `(\"\")`.\n// It is shortcut for `c.Request.URL.Query().Get(key)`\n//     GET /path?id=1234&name=Manu&value=\n// 	   c.Query(\"id\") == \"1234\"\n// 	   c.Query(\"name\") == \"Manu\"\n// 	   c.Query(\"value\") == \"\"\n// 	   c.Query(\"wtf\") == \"\"\nfunc (c *Context) Query(key string) string {\n	value, _ := c.GetQuery(key)\n	return value\n}\n\n// DefaultQuery returns the keyed url query value if it exists,\n// otherwise it returns the specified defaultValue string.\n// See: Query() and GetQuery() for further information.\n//     GET /?name=Manu&lastname=\n//     c.DefaultQuery(\"name\", \"unknown\") == \"Manu\"\n//     c.DefaultQuery(\"id\", \"none\") == \"none\"\n//     c.DefaultQuery(\"lastname\", \"none\") == \"\"\nfunc (c *Context) DefaultQuery(key, defaultValue string) string {\n	if value, ok := c.GetQuery(key); ok {\n		return value\n	}\n	return defaultValue\n}\n```\n\n从上述源代码中可以发现，两者都调用了 `c.GetQuery(key)` 函数，接下来，我们来跟踪一下源代码：\n\n```go\n// GetQuery is like Query(), it returns the keyed url query value\n// if it exists `(value, true)` (even when the value is an empty string),\n// otherwise it returns `(\"\", false)`.\n// It is shortcut for `c.Request.URL.Query().Get(key)`\n//     GET /?name=Manu&lastname=\n//     (\"Manu\", true) == c.GetQuery(\"name\")\n//     (\"\", false) == c.GetQuery(\"id\")\n//     (\"\", true) == c.GetQuery(\"lastname\")\nfunc (c *Context) GetQuery(key string) (string, bool) {\n	if values, ok := c.GetQueryArray(key); ok {\n		return values[0], ok\n	}\n	return \"\", false\n}\n\n// GetQueryArray returns a slice of strings for a given query key, plus\n// a boolean value whether at least one value exists for the given key.\nfunc (c *Context) GetQueryArray(key string) ([]string, bool) {\n	c.getQueryCache()\n	if values, ok := c.queryCache[key]; ok && len(values) > 0 {\n		return values, true\n	}\n	return []string{}, false\n}\n```\n\n在 `c.GetQuery(key)` 函数内部调用了 `c.GetQueryArray(key)` 函数，而在 `c.GetQueryArray(key)` 函数中，先是调用了 `c.getQueryCache()` 函数，之后即可通过 `key` 直接从 `c.queryCache` 中获取对应的 `value` 值，基本上可以确定 `c.getQueryCache()` 函数的作用就是把查询字符串参数存储到 `c.queryCache` 中。下面，我们来看一下`c.getQueryCache()` 函数的源代码：\n\n```go\nfunc (c *Context) getQueryCache() {\n	if c.queryCache == nil {\n		c.queryCache = c.Request.URL.Query()\n	}\n}\n```\n\n先是判断 `c.queryCache` 的值是否为 `nil`，如果为 `nil`，则调用 `c.Request.URL.Query()` 函数；否则，不做处理。\n\n我们把关注点放在 `c.Request` 上面，其为 `*http.Request` 类型，位于 Go 自带函数库中的 net/http 库，而 `c.Request.URL` 则位于 Go 自带函数库中的 net/url 库，表明接下来的源代码来自 Go 自带函数库中，我们来跟踪一下源代码：\n\n```go\n// Query parses RawQuery and returns the corresponding values.\n// It silently discards malformed value pairs.\n// To check errors use ParseQuery.\nfunc (u *URL) Query() Values {\n	v, _ := ParseQuery(u.RawQuery)\n	return v\n}\n\n// Values maps a string key to a list of values.\n// It is typically used for query parameters and form values.\n// Unlike in the http.Header map, the keys in a Values map\n// are case-sensitive.\ntype Values map[string][]string\n\n// ParseQuery parses the URL-encoded query string and returns\n// a map listing the values specified for each key.\n// ParseQuery always returns a non-nil map containing all the\n// valid query parameters found; err describes the first decoding error\n// encountered, if any.\n//\n// Query is expected to be a list of key=value settings separated by\n// ampersands or semicolons. A setting without an equals sign is\n// interpreted as a key set to an empty value.\nfunc ParseQuery(query string) (Values, error) {\n	m := make(Values)\n	err := parseQuery(m, query)\n	return m, err\n}\n\nfunc parseQuery(m Values, query string) (err error) {\n	for query != \"\" {\n		key := query\n		// 如果key中存在\'&\'或者\';\', 则用其对key进行分割\n		// 例如切割前: key = firstname=Les&lastname=An\n		// 例如切割后: key = firstname=Les, query = lastname=An\n		if i := strings.IndexAny(key, \"&;\"); i >= 0 {\n			key, query = key[:i], key[i+1:]\n		} else {\n			query = \"\"\n		}\n		if key == \"\" {\n			continue\n		}\n		value := \"\"\n		// 如果key中存在\'=\', 则用其对key进行分割\n		// 例如切割前: key = firstname=Les\n		// 例如切割后: key = firstname, value = Les\n		if i := strings.Index(key, \"=\"); i >= 0 {\n			key, value = key[:i], key[i+1:]\n		}\n		// 对key进行转义处理\n		key, err1 := QueryUnescape(key)\n		if err1 != nil {\n			if err == nil {\n				err = err1\n			}\n			continue\n		}\n		// 对value进行转义处理\n		value, err1 = QueryUnescape(value)\n		if err1 != nil {\n			if err == nil {\n				err = err1\n			}\n			continue\n		}\n		// 将value追加至m[key]切片中\n		m[key] = append(m[key], value)\n	}\n	return err\n}\n```\n\n首先是 `u.Query()` 函数，通过解析 `RawQuery` 的值，以上面 GET 请求为例，则其 `RawQuery` 值为 `firstname=Les&lastname=An`，返回值为一个 `Values` 类型的对象，`Values` 为一个 key 类型为字符串，value 类型为字符串切片的 map。\n\n然后是 `ParseQuery(query)` 函数，在该函数中创建了一个 `Values` 类型的对象 `m`，并用其和传递进来的 `query` 作为 `parseQuery(m, query)` 函数的参数。\n\n最后在 `parseQuery(m, query)` 函数内将 `query` 解析至 `m`中，至此，查询字符串参数解析完毕。\n\n### 总结\n\n这篇文章讲解了 Gin 中的 URL 参数解析的两种方式，分别是路径中的参数解析和查询字符串的参数解析。\n\n其中，路径中的参数解析过程结合了 Gin 中的路由匹配机制，由于路由匹配机制的巧妙设计，使得这种方式的参数解析非常高效，当然，路由匹配机制稍微有些许复杂，这在本系列后续的文章中将会进行详细讲解；然后是查询字符的参数解析，这种方式的参数解析与 Go 自带函数库 net/url 库的区别就是，Gin 将解析后的参数保存在了上下文中，这样的话，对于获取多个参数时，则无需对查询字符串进行重复解析，使获取多个参数时的效率提高了不少，这也是 Gin 为何效率如此之快的原因之一。\n\n至此，本文也就结束了，感谢大家的阅读，本系列的下一篇文章将讲解 POST 请求中的表单数据是如何解析的。\n\n', 0, '2020-02-13 13:51:27', '2020-03-13 13:51:30', '2020-03-13 13:51:33', NULL);
INSERT INTO `blog_posts` VALUES (3, 'Cole Lie', 'Gin 源码学习（二）丨请求体中的参数是如何解析的？', 'gin-how-parsing-param-from-request-body1', 'Gin 是如何解析请求体中的参数的？', '# Gin 源码学习（二）丨请求体中的参数是如何解析的？', 0, '2020-02-01 13:52:28', '2020-03-13 13:52:24', '2020-03-13 13:52:26', NULL);
INSERT INTO `blog_posts` VALUES (4, 'Cole Lie', 'Gin 源码学习（三）丨请求体中的参数是如何解析的？', 'gin-how-parsing-param-from-request-body2', 'Gin 是如何解析请求体中的参数的？', '# Gin 源码学习（二）丨请求体中的参数是如何解析的？', 0, '2020-03-13 13:52:29', '2020-03-13 13:52:24', '2020-03-13 13:52:26', NULL);
INSERT INTO `blog_posts` VALUES (5, 'Cole Lie', 'Gin 源码学习（四）丨请求体中的参数是如何解析的？', 'gin-how-parsing-param-from-request-body3', 'Gin 是如何解析请求体中的参数的？', '# Gin 源码学习（二）丨请求体中的参数是如何解析的？', 0, '2020-03-13 13:52:30', '2020-03-13 13:52:24', '2020-03-13 13:52:26', NULL);
INSERT INTO `blog_posts` VALUES (6, 'Cole Lie', 'Gin 源码学习（五）丨请求体中的参数是如何解析的？', 'gin-how-parsing-param-from-request-body4', 'Gin 是如何解析请求体中的参数的？', '# Gin 源码学习（二）丨请求体中的参数是如何解析的？', 0, '2020-03-13 13:52:31', '2020-03-13 13:52:24', '2020-03-13 13:52:26', NULL);
INSERT INTO `blog_posts` VALUES (7, 'Cole Lie', 'Gin 源码学习（六）丨请求体中的参数是如何解析的？', 'gin-how-parsing-param-from-request-body5', 'Gin 是如何解析请求体中的参数的？', '# Gin 源码学习（二）丨请求体中的参数是如何解析的？', 0, '2020-03-13 13:53:28', '2020-03-13 13:52:24', '2020-03-13 13:52:26', NULL);
INSERT INTO `blog_posts` VALUES (8, 'Cole Lie', 'Gin 源码学习（七）丨请求体中的参数是如何解析的？', 'gin-how-parsing-param-from-request-body6', 'Gin 是如何解析请求体中的参数的？', '# Gin 源码学习（二）丨请求体中的参数是如何解析的？', 0, '2020-03-13 13:54:28', '2020-03-13 13:52:24', '2020-03-13 13:52:26', NULL);
INSERT INTO `blog_posts` VALUES (9, 'Cole Lie', 'Gin 源码学习（八）丨请求体中的参数是如何解析的？', 'gin-how-parsing-param-from-request-body7', 'Gin 是如何解析请求体中的参数的？', '# Gin 源码学习（二）丨请求体中的参数是如何解析的？', 0, '2020-03-13 13:55:28', '2020-03-13 13:52:24', '2020-03-13 13:52:26', NULL);
INSERT INTO `blog_posts` VALUES (10, 'Cole Lie', 'Gin 源码学习（九）丨请求体中的参数是如何解析的？', 'gin-how-parsing-param-from-request-body8', 'Gin 是如何解析请求体中的参数的？', '# Gin 源码学习（二）丨请求体中的参数是如何解析的？', 0, '2020-03-13 14:52:28', '2020-03-13 13:52:24', '2020-03-13 13:52:26', NULL);
INSERT INTO `blog_posts` VALUES (11, 'Cole Lie', 'Gin 源码学习（十）丨请求体中的参数是如何解析的？', 'gin-how-parsing-param-from-request-body9', 'Gin 是如何解析请求体中的参数的？', '# Gin 源码学习（二）丨请求体中的参数是如何解析的？', 0, '2020-03-13 15:52:28', '2020-03-13 13:52:24', '2020-03-13 13:52:26', NULL);

-- ----------------------------
-- Table structure for blog_tags
-- ----------------------------
DROP TABLE IF EXISTS `blog_tags`;
CREATE TABLE `blog_tags`  (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID，自增主键',
  `value` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标签值，唯一',
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标签名',
  `created_at` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `deleted_at` timestamp(0) NULL DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '博客文章标签表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of blog_tags
-- ----------------------------
INSERT INTO `blog_tags` VALUES (1, 'go', 'Go', '2020-03-13 13:47:46', '2020-03-13 13:47:42', NULL);
INSERT INTO `blog_tags` VALUES (2, 'gin', 'Gin', '2020-03-13 13:47:48', '2020-03-13 14:23:41', NULL);

SET FOREIGN_KEY_CHECKS = 1;
