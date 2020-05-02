module libester.client;

import std.socket : Socket, AddressFamily, SocketType, ProtocolType, parseAddress;
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
        serverSocket = new Socket(AddressFamily.INET, SocketType.STREAM, ProtocolType.TCP);
        serverSocket.connect(parseAddress(serverAddress, serverPort));

        /* TODO: Error handling */
    }

    public void authenticate(string username, string password)
    {
        /* Make sure we have an open connection */
        if(serverSocket is null)
        {
            /* TODO: Raise exception */
        }

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

        if(netStatus)
        {
            /* Receive a response */
            JSONValue serverResponse;
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
            /* TODO: Throw exception for failed authentication */
        }
    }

    public void close()
    {
        /* Whether or not the authentication succeded */
        bool status = true;

        /* Construct the authentication payload */
        // JSONValue payload;
        // JSONValue headerBlock;
        // headerBlock[""]
        // payload["header"] = headerBlock;
    }

}