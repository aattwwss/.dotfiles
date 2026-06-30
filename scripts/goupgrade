#!/usr/bin/env bash

# Fetch the latest version from the Go website
VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n 1)

# Set the GOTOOLCHAIN environment variable to the latest version with auto update enabled
go env -w GOTOOLCHAIN="${VERSION}+auto"

# Verify the changes
echo "GOTOOLCHAIN has been set to: $(go env GOTOOLCHAIN)"

go version
