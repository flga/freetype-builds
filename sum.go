package main

import (
	"crypto/sha256"
	"fmt"
	"io"
	"os"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "missing file name")
		os.Exit(1)
		return
	}

	path := os.Args[1]
	data, err := sum(path)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
		return
	}

	if data == nil || len(data) != sha256.Size {
		os.Exit(1)
		return
	}

	fmt.Printf("SHA256 %x %s\n", data, path)
}

func sum(path string) ([]byte, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	h := sha256.New()
	if _, err := io.Copy(h, f); err != nil {
		return nil, err
	}

	return h.Sum(nil), nil
}
