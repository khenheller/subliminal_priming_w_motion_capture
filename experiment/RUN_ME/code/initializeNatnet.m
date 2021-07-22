function [natnetclient] = initializeNatnet(varargin)

    if length(varargin)==1
        ip = varargin{1};
    else
        ip = '127.0.0.1';
    end
    
    natnetclient = natnet;

    fprintf( 'Connecting to the server\n' )
    natnetclient.HostIP = ip;
    natnetclient.ClientIP = ip;
    natnetclient.ConnectionType = 'Multicast';
    natnetclient.connect;
    if ( natnetclient.IsConnected == 0 )
        fprintf( 'Client failed to connect\n' )
        fprintf( '\tMake sure the host is connected to the network\n' )
        fprintf( '\tand that the host and client IP addresses are correct\n\n' ) 
        return
    end
end
