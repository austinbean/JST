


#Sample Data for Stan.  Following Geweke/Keane
"""
`DataGen1(n::Int64)`
Generates simple data.
"""
function DataGen1(n::Int64)
    srand(1) # sets random seed.
    outp = zeros(n)
    β1 = 0.0
    β2 = 1.0
    β3 = -1.0
    for i = 1:n 
        outp[i] = β1 + β2*randn() + β3*randn() + randn()
    end 
    return outp 
end 


"""
`DataGen2(n::Int64)`
Same DGP as previous set, but now censors.
Censors data based on greater than 0 or not.
"""
function DataGen2(n::Int64)
    srand(1) # sets random seed.
    outp = zeros(n)
    β1 = 0.0
    β2 = 1.0
    β3 = -1.0
    for i = 1:n 
        outp[i] = β1 + max(β2*randn() + β3*randn() + randn(), 0.0)
    end 
    return outp 
end 

"""
`DataGen3(n::Int64)`
Same DGP as previous set, but now does not 
report the value of the latent variable v1.
You get either 1 or 2 depending on the value 
of the latent v1.
"""
function DataGen3(n::Int64)
    srand(1) # sets random seed.
    outp = zeros(n)
    β1 = 0.0
    β2 = 1.0
    β3 = -1.0
    for i = 1:n 
        v1 = β1 + β2*randn() + β3*randn() + randn()
        if v1 >= 0
            outp[i] = 1 # not sure exactly what this should look like.  
        else
            outp[i] = 2
        end 
    end 
    return outp 
end 




