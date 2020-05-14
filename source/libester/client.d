module libester.client;

import std.socket : Socket, AddressFamily, SocketType, ProtocolType, parseAddress, SocketOSException, SocketException;
import libester.execeptions;
import std.string : cmp;
import bmessage : receiveMessage, sendMessage;
import std.json : JSONValue, JSONException;

public final class BesterClient
{

    /* Bester server endpoint */
    private string serverAddress;
    private ushort serverPort;

    /* Socket to server */
    private Socket serverSocket;

    this(string serverAddress, ushort serverPort)
    {
        /* Make sure the `serverAddress` and `serverPort` are valid */
        try
        {
            parseAddress(serverAddress, serverPort);
        }
        catch(SocketException)
        {
            throw new BesterException("Invalid network parameters");
        }

        /* Setup endpoint */
        this.serverAddress = serverAddress;
        this.serverPort = serverPort;
    }

    public void connect()
    {
        try
        {
            serverSocket = new Socket(AddressFamily.INET, SocketType.STREAM, ProtocolType.TCP);
            serverSocket.connect(parseAddress(serverAddress, serverPort));
        }
        catch(SocketOSException)
        {
            serverSocket = null;
        }
    }

    private void endpointConnectednessCheck()
    {
        if(serverSocket is null)
        {
            /* Raise exception */
            throw new BesterException("Endpoint not connected");
        }
    }

    /**
     * Authenticates the user to the server.
     *
     * The credentials to authenticate with are `username`
     * and `password` and are both of type `string`.
     *
     * Throws a `BesterException` exception if the
     * endpoint is not connected or on general error
     * or if authentication fails.
     *
     * Returns a `JSONValue` struct with the status.
     */
    public bool authenticate(string username, string password)
    {
        /* Make sure we have an open connection */
        endpointConnectednessCheck();

        /* Whether or not the authentication succeded */
        bool status = true;

        /* Construct the login message */
        JSONValue message;

        /* Create the `header` block */
        JSONValue headerBlock;

        /* Create the `authentication` block and attach it to the `header` block */
        JSONValue authenticationBlock;
        authenticationBlock["username"] = username;
        authenticationBlock["password"] = password;
        headerBlock["authentication"] = authenticationBlock;

        /* Set the `scope` field */
        headerBlock["scope"] = "client";

        /* Add a dummy `payload` block */
        JSONValue payloadBlock;
        payloadBlock["data"] = null;
        payloadBlock["type"] = "dummy"; /* TODO: Add to spec */
        //payloadBlock["id"] = "auth_special";
        message["payload"] = payloadBlock;

        /* Attach the `header` block to the payload */
        message["header"] = headerBlock;

        bool netStatus;

        /* Send the message to the server */
        netStatus = sendMessage(serverSocket, message);

        /* The server's response */
        JSONValue serverResponse;

        if(netStatus)
        {
            /* Receive a response */
            netStatus = receiveMessage(serverSocket, serverResponse);

            if(netStatus)
            {
                try
                {
                    /* Now get the `status` block */
                    JSONValue statusBlock = serverResponse["header"]["status"];

                    /* Check the code */
                    string statusCode = statusBlock.str();

                    /* Valid authentication would be "5" */
                    if(cmp(statusCode, "good") == 0)
                    {
                        /* Authentication succeeded */
                        /* TODO: Debug print */
                    }
                    else
                    {
                        /* Authentication failure */
                        /* TODO: Debug print */
                        status = false;
                    }
                }
                catch(JSONException e)
                {
                    status = false;
                }
            }
            else
            {
                status = false;
            }
        }
        else
        {
            status = false;
        }

        if(!status)
        {
            /* TODO: Nullify */
            serverSocket = null;

            /* TODO: Throw exception for failed authentication */
            throw new BesterException("Authentication failed");
        }
        
        return status;
    }

    /**
     * Receives a message off the message queue and
     * returns it as a JSON value.
     *
     * Throws a `BesterException` exception if the
     * endpoint is not connected or on general error.
     *
     * Returns a `JSONValue` struct.
     */
    public JSONValue receive()
    {
        /* Make sure we have an open connection */
        endpointConnectednessCheck();

        /* The received message */
        JSONValue receivedMessage;

        /* TODO: Error handling; Receives a message */
        bool receiveStatus = receiveMessage(serverSocket, receivedMessage);

        if(!receiveStatus)
        {
            /* TODO: Nullify */
            serverSocket = null;
            throw new BesterException("Error receiving message from server");
        }

        return receivedMessage;
    }

    public void send(string type, JSONValue data)
    {
        /* Make sure we have an open connection */
        endpointConnectednessCheck();

        /* TODO: Implement me */

        /* Construct the `header` block */
        JSONValue headerBlock;


        /* Construct the `payload` block */
        JSONValue payloadBlock;

        /* Set the type */
        payloadBlock["type"] = type;
        
        /* Set the data */
        payloadBlock["data"] = data;


        /* The message */
        JSONValue message;
        message["header"] = headerBlock;
        message["payload"] = payloadBlock;

        sendMessage(serverSocket, message);
    }

    /**
     * Closes the active connection.
     *
     * Throws a `BesterException` exception if the
     * endpoint is not connected or on general error.
     *
     * Returns a `JSONValue` struct with the status of
     * the `close`.
     */
    public JSONValue close()
    {
        /* Make sure we have an open connection */
        endpointConnectednessCheck();

        /* The received message */
        JSONValue receivedMessage;

        /* Whether or not the authentication succeded */
        bool status = true;

        /* Construct the authentication payload */
        // JSONValue payload;
        // JSONValue headerBlock;
        // headerBlock[""]
        // payload["header"] = headerBlock;

        return receivedMessage;
    }

}