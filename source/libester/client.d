module libester.client;

import std.socket : Socket, AddressFamily, SocketType, ProtocolType, parseAddress, SocketOSException;
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
        /* Setup endpoint */
        this.serverAddress = serverAddress;
        this.serverPort = serverPort;

        /* TODO: Range check for port */
        /* TODO: Make sure string is non-empty */
        if(cmp(serverAddress, "") == 0)
        {
            /* TODO: This is an error */
            // throw new EndpointException();
        }
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
    public JSONValue authenticate(string username, string password)
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
        message["payload"] = payloadBlock;

        /* Attach the `header` block to the payload */
        message["header"] = headerBlock;

        bool netStatus;

        /* Send the message to the server */
        netStatus = sendMessage(serverSocket, message);

        JSONValue serverResponse;;

        if(netStatus)
        {
            /* Receive a response */
            netStatus = receiveMessage(serverSocket, serverResponse);

            if(netStatus)
            {
                try
                {
                    /* Now get the `status` block */
                    JSONValue statusBlock = serverResponse["status"];

                    /* Check the code */
                    string statusCode = statusBlock["code"].str();

                    /* Valid authentication would be "5" */
                    if(cmp(statusCode, "5") == 0)
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
        else
        {
            return serverResponse;
        }
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