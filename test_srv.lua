srv=net.createServer(net.TCP)
packet = 0
bodyStartFound = false
handled = false
length = 0
srv:listen(80,function(conn)
  conn:on("receive", function(conn, data)
    print("Packet: "..packet)
    if packet == 0 then
      _, _, request, path, query = data:find("([^ ]+) ([^ ?]+)%??([^ ]*)")
      -- Grab the body length:
      _, _, length, rest = data:find("Content%-Length:%s(%d+)(.*)")
      length = tonumber(length)
      -- Print the request:
      print("Request: "..request)
      print("  Path: "..path)
      if length ~= nil then
        print("  Content-Length: "..length)
      end
      
      filename=path:sub(2)
      if request == "POST" then
        action = "edit"
      elseif request == "GET" then
        if query == "do" then
          action = "do"
        else
          action = "read"
        end
      else
        action = "unknown"
      end
      print("  Action: "..action)
    end
    if action == "read" then
      -- TODO: Send the file back
    elseif action == "do" then
      print("Running file '"..filename.."'.")
      dofile(filename)
      conn:send("Running file '"..filename.."'.")
    elseif action == "edit" then
      if not bodyStartFound then
        _, bodyStart = data:find("\r\n\r\n")
        if bodyStart ~= nil then
          print("Found start of body data")
          bodyStartFound = true
          -- Grab until length is exhausted or packet ends:
          if data:len() > bodyStart+length then
            bodyEnd = bodyStart+length
            print("Grabbing the full "..length.." bytes of body data.")
          else
            bodyEnd = data:len()
            print("Grabbing the rest of the packet.")
          end
          dataGrabbed = bodyEnd-bodyStart
          print("Saving '"..filename.."'.");
          file.open(filename, "w")
          file.write(data:sub(bodyStart+1, bodyEnd))
          file.close()
        end
      else
        -- Grab until length is exhausted or packet ends:
        if data:len() > length-dataGrabbed then
          bodyEnd = length-dataGrabbed
        else
          bodyEnd = data:len()
        end
        if bodyEnd > 0 then
          dataGrabbed = dataGrabbed + bodyEnd
          file.open(filename, "a+")
          file.write(data:sub(1, bodyEnd))
        end
      end
      
      packet = packet + 1
      print("Data grabbed: "..dataGrabbed.."/"..length)
      
      if (not handled) and (dataGrabbed == length) then
        print("All data grabbed, done with request.")
        conn:send("File '"..filename.."' saved.")
        handled = true
      end
    end
  end)
  conn:on("sent",function(conn) 
    packet = 0
    bodyStartFound = false
    handled = false
    length = 0
    conn:close() 
    
  end)
end)