package model

import (
	"fmt"
	. "github.com/hkail/blog/conf"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/mysql"
	"log"
)

var DB *gorm.DB

func init() {
	var err error
	DB, err = gorm.Open("mysql", fmt.Sprintf("%s:%s@(%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		Conf.DBConf.User,
		Conf.DBConf.Pwd,
		Conf.DBConf.Addr,
		Conf.DBConf.Name))

	if err != nil {
		log.Fatalf("Database open error: %v", err)
	}
	DB.LogMode(Conf.DBConf.LogMode)
}

func calOffset(pi, ps int) int {
	return (pi - 1) * ps
}
