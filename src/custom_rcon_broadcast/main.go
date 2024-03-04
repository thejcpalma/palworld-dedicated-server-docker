/*
    Author: João Palma
    Project Name: thejcpalma/palworld-dedicated-server-docker
    GitHub: https://github.com/thejcpalma/palworld-dedicated-server-docker
    DockerHub: https://hub.docker.com/r/thejcpalma/palworld-dedicated-server
*/

package main

import (
    "bytes"
    "encoding/binary"
    "flag"
    "fmt"
    "os"
    "log"
    "net"
	"strconv"
    "strings"
    "gopkg.in/yaml.v2"
)

// ServerConfig is a structure that holds the configuration details for the RCON server.
// It is used to unmarshal the YAML configuration file provided by the user.
// The struct has one field, Default, which is an anonymous struct.
//
// The Default struct has two fields:
// Address: This is a string that holds the IP address and port of the RCON server.
//          It is expected to be in the format "ip:port".
// Password: This is a string that holds the password for the RCON server.
//
// The yaml tags are used to map the struct fields to the corresponding keys in the YAML file.
type ServerConfig struct {
    Default struct {
        Address  string `yaml:"address"`  // The IP address and port of the RCON server
        Password string `yaml:"password"` // The password for the RCON server
    } `yaml:"default"` // The default configuration for the RCON server
}


// sendRconCommand sends a command to a RCON server and returns the server's response.
// It establishes a TCP connection to the server, authenticates using the provided password,
// sends the command, and reads the server's response.
// sendRconCommand sends an RCON command to a server and returns the server's response.
// It establishes a TCP connection to the RCON server using the provided IP address and port.
// The authentication packet is created with the provided password and sent to the server.
// If the authentication is successful, a command packet is created with the provided command and sent to the server.
// The server's response to the command packet is read and returned as a string.
// If any error occurs during the process, an error is returned.
func sendRconCommand(ip string, port int, password string, command string) (string, error) {
    // Establish a TCP connection to the RCON server.
    conn, err := net.Dial("tcp", fmt.Sprintf("%s:%d", ip, port))
    if err != nil {
        return "", err
    }
    defer conn.Close()

    // Create an authentication packet.
    // The packet consists of a little-endian int32 length field, a little-endian int32 request ID field,
    // a little-endian int32 type field, the password as a null-terminated string, and two null bytes.
    authPacket := new(bytes.Buffer)
    binary.Write(authPacket, binary.LittleEndian, int32(10+len(password))) // Length
    binary.Write(authPacket, binary.LittleEndian, int32(1)) // Request ID
    binary.Write(authPacket, binary.LittleEndian, int32(3)) // Type
    authPacket.WriteString(password) // Password
    authPacket.Write([]byte{0, 0}) // Null bytes

    // Send the authentication packet to the server.
    _, err = conn.Write(authPacket.Bytes())
    if err != nil {
        return "", err
    }

    // Read the server's response to the authentication packet.
    authResponse := make([]byte, 4096)
    _, err = conn.Read(authResponse)
    if err != nil {
        return "", err
    }

    // Check the server's response to the authentication packet.
    // If the response ID is -1, the authentication failed.
    responseID := int32(binary.LittleEndian.Uint32(authResponse[4:8]))
    if responseID == -1 {
        return "", fmt.Errorf("authentication failed")
    }

    // Create a command packet.
    // The packet consists of a little-endian int32 length field, a little-endian int32 request ID field,
    // a little-endian int32 type field, the command as a null-terminated string, and two null bytes.
    commandBytes := append([]byte(command), 0, 0)
    commandPacket := new(bytes.Buffer)
    binary.Write(commandPacket, binary.LittleEndian, int32(10+len(commandBytes)-2)) // Length
    binary.Write(commandPacket, binary.LittleEndian, int32(2)) // Request ID
    binary.Write(commandPacket, binary.LittleEndian, int32(2)) // Type
    commandPacket.Write(commandBytes) // Command

    // Send the command packet to the server.
    _, err = conn.Write(commandPacket.Bytes())
    if err != nil {
        return "", err
    }

    // Read the server's response to the command packet.
    responsePacket := make([]byte, 4096)
    _, err = conn.Read(responsePacket)
    if err != nil {
        return "", err
    }

    // Extract the body of the server's response from the response packet.
    responseBody := string(responsePacket[12 : len(responsePacket)-2])

    return responseBody, nil
}


// main is the entry point of the program.
// It parses command-line flags, reads a configuration file, sends the 'broadcast' command to the Palworld RCON server,
// and prints the server's response.
func main() {
    // Parse command-line flags
    configPath := flag.String("c", "", "Path to the YAML configuration file")
    flag.Parse()

    // Check if a configuration file was provided
    if *configPath == "" {
        log.Fatal("Please provide a configuration file with the -c flag.")
    }

    // Read the configuration file
    configData, err := os.ReadFile(*configPath)
    if err != nil {
        log.Fatal(err)
    }

    // Parse the configuration file
    var config ServerConfig
    err = yaml.Unmarshal(configData, &config)
    if err != nil {
        log.Fatal(err)
    }

    // Split the address into IP and port
    splitAddress := strings.Split(config.Default.Address, ":")
    ip := splitAddress[0]
    port, err := strconv.Atoi(splitAddress[1])
    if err != nil {
        log.Fatal(err)
    }

    // Check if a message was provided
    if len(flag.Args()) < 1 {
        log.Fatal("Please provide a message as a command-line argument.")
    }

    // Get the message from the command-line arguments
    message := flag.Args()[0]
    modded_message := strings.ReplaceAll(message, " ", "\xa0") // Replace spaces with non-breaking spaces
    command := "broadcast " + modded_message // Construct the command

    // Send the command to the RCON server and print the server's response.
    result, err := sendRconCommand(ip, port, config.Default.Password, command)
    if err != nil {
        log.Fatal(err)
    }

	// Check if the server's response indicates that the message was broadcasted
	if strings.HasPrefix(result, "Broadcasted:") {
		// Prints the message that was broadcasted
		fmt.Println("Broadcasted: " + message)
	} else {
		fmt.Println("Error on broadcast!")
	}
}
