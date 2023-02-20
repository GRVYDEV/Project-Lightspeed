package ingest

import (
	"fmt"
	"io"
	"log"
	"os/exec"
)

type IngestServer struct {
	cmd *exec.Cmd
}

type IngestServerConfig struct {
	Path      string
	Addr      string
	StreamKey string
	LogFile   string
}

func NewIngestServer(config IngestServerConfig) *IngestServer {
	args := make([]string, 0)
	if config.Addr != "" {
		args = append(args, fmt.Sprintf("-a=%s", config.Addr))
	}
	if config.StreamKey != "" {
		args = append(args, fmt.Sprintf("-k=%s", config.StreamKey))
	}
	if config.LogFile != "" {
		args = append(args, fmt.Sprintf("-l=%s", config.LogFile))
	}

	return &IngestServer{
		cmd: exec.Command(config.Path, args...),
	}
}

// StartIngest tries to start the ingest server and logs its stdout
func (s *IngestServer) Start() error {
	stdout, err := s.cmd.StdoutPipe()
	if err != nil {
		return err
	}
	err = s.cmd.Start()
	if err != nil {
		return err
	}

	//TODO Handle shutdown logic
	go s.logger(stdout)
	go s.waitForExit()
	return nil
}

func (s *IngestServer) logger(stdout io.ReadCloser) {
	for {
		buf := make([]byte, 1096)
		_, err := stdout.Read(buf)
		if err == io.EOF {
			break
		}
		line := string(buf)
		fmt.Print(line)
	}
}

func (s *IngestServer) waitForExit() error {
	err := s.cmd.Wait()
	if err != nil {
		log.Fatal(err)
	}
	return err
}
