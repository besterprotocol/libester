module libester.client;

import std.socket : Socket;
import libester.execeptions;
import std.string : cmp;
import bmessage;
import std.json : JSONValue;

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

    public void authenticate(string username, string password)
    {
        /* Construct the authentication payload */
        JSONValue payload;
        JSONValue headerBlock;
        JSONValue authenticationBlock;
        authenticationBlock["username"] = username;
        authenticationBlock["password"] = password;
        headerBlock["authentication"] = authenticationBlock;
        payload["header"] = headerBlock;

        /* Send the message to the server */
        /* TODO: Error handling */
        sendMessage(serverSocket, payload);
    }


}