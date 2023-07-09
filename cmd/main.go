package main

import (
	"time"

	"github.com/egandro/signoz-bugos/pkg/logger"
	"github.com/google/uuid"
	"github.com/sirupsen/logrus"
)

func main() {
	log := logger.Get().Logrus

	for {
		lg := log.WithFields(logrus.Fields{
			"customer_id": uuid.NewString(),
			"product_id":  uuid.NewString(),
			"database":    "DC/EU/WEST",
		})
		lg.Debug("debug message")
		lg.Infof("info message")
		lg.Errorf("Error message")
		time.Sleep(5 * time.Second)
	}
}

// this will create log message like this

// what we want in SigNoz
// customer_id, database, level, product_id stripped from body and put into attributes

/*
{"customer_id":"d2c1ad43-70a5-4e8b-aa3d-d92d0cc4eb49","database":"DC/EU/WEST","level":"debug","message":"debug message","product_id":"de733801-0f7a-45fa-a5d3-e9e6ae0b859a"}
{"customer_id":"d2c1ad43-70a5-4e8b-aa3d-d92d0cc4eb49","database":"DC/EU/WEST","level":"info","message":"info message","product_id":"de733801-0f7a-45fa-a5d3-e9e6ae0b859a"}
{"customer_id":"d2c1ad43-70a5-4e8b-aa3d-d92d0cc4eb49","database":"DC/EU/WEST","level":"error","message":"Error message","product_id":"de733801-0f7a-45fa-a5d3-e9e6ae0b859a"}
*/
