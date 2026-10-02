function process(text)

    local _, _, n1, o, n2 = string.find(text, "(%d+)([%+%-&/%*])(%d+)")

    n1 = tonumber(n1, 10)

    n2 = tonumber(n2, 10)

    
    
    if o =="+" then
        return n1+n2
        

    elseif o =="-" then
        return n1-n2

    elseif o =="/" then
    return n1/n2

    elseif o =="*" then
    return n1*n2
end



    
end

print(": ")
t = io.read("*l")

print(process(t))