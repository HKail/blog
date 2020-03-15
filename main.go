package main

import (
	. "github.com/hkail/blog/conf"
	"github.com/hkail/blog/router"
	"log"
	"net/http"
)

func main() {
	server := http.Server{
		Handler: router.R,
		Addr:    Conf.SysConf.Port,
	}

	log.Fatal(server.ListenAndServe())
}
