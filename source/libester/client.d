module libester.client;

import std.socket : Socket;
import libester.execeptions;
import std.string : cmp;
import bmessage;

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
        sendMessage_internal();
    }


}