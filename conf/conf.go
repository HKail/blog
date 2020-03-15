package conf

import (
	"encoding/json"
	"io/ioutil"
	"os"
)

var Conf conf

const configFile = "./conf.json"

const testConfigFile = "../conf.json"

func init() {
	bytes, err := ioutil.ReadFile(configFile)
	if err != nil {
		if _, ok := err.(*os.PathError); ok {
			bytes, err = ioutil.ReadFile(testConfigFile)
			if err != nil {
				panic(err)
			}
		}
	}
	err = json.Unmarshal(bytes, &Conf)
	if err != nil {
		panic(err)
	}
}

type conf struct {
	SysConf sysConf `json:"sys_conf"`
	DBConf  dbConf  `json:"db_conf"`
}

type sysConf struct {
	Port      string
	SecretKey string `json:"secret_key"`
	PageSize  int    `json:"page_size"`
}

type dbConf struct {
	Addr    string
	User    string
	Pwd     string
	Name    string
	LogMode bool `json:"log_mode"`
}
