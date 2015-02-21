srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
  conn:on("receive", function(conn, data)
    -- Grab the request type:
    i = data:find(" ", 1)
    request = data:sub(1, i-1)
    -- Grab the URI
    uriStart = i+1
    i = data:find(" ", i+1)
    uri = data:sub(uriStart, i-1)
    -- Grab the body length:
    _, _, length = data:find("Content%-Length:%s(%d+)", i+1)
    -- Grab the body content:
    i, bodyStart = data:find("\r\n\r\n", i+1)
    body = data:sub(bodyStart, bodyStart+length)
    -- Print the request:
    print("Request: "..request)
    print("  URI: "..uri)
    print("  Body: "..body)
    
    -- Handle the request:
    if request == "POST" then
      if uri == "/upload" then
        _, filestart, filename = body:find("([^\r\n]+)")
        print("Saving file to "..filename)
        file.remove(filename)
        file.open(filename, 'w')
        file.write(body:sub(filestart+1))
        file.close()
        conn:send("File '"..filename)
      end
    end
    
    --conn:send("Hello!")
  end)
  conn:on("sent",function(conn) conn:close() end)
end)