module GRF

# using ARCHModels       
using Cbc               
using CSV
using Dates             
using DataFrames
using Distributions     
# using HypothesisTests   
using HTTP
using Ipopt             
using JSON
using JuMP              
using Juniper          
# using LinearAlgebra    
# using Random           
using Statistics        
using StatsPlots       

include("modulo01.jl")

# using Pkg
# println(haskey(Pkg.installed(), "JuMP"))

#=
nikkein = CSV.read("NIKKEI225n.csv", DataFrame)
println(nikkein[!,:Simbolo])
=#

#=
nikkeic = yahoo(NIKKEI225n, Date(2015,12,31), Date(2021,3,31))
println(describe(nikkeic))
CSV.write("NIKKEI225c.csv", nikkeic)
nikkeir = retornos(nikkeic, :log)
CSV.write("NIKKEI225r.csv", nikkeir)
=#

#=
mibn = CSV.read("FTSEMIBn.csv", DataFrame)
println(mibn[!,:Simbolo])
=#

#=
mibc = yahoo(FTSEMIBn, Date(2015,12,31), Date(2021,3,31))
println(describe(mibc))
CSV.write("FTSEMIBc.csv", mibc)
mibr = retornos(mibc, :log)
CSV.write("FTSEMIBr.csv", mibr)
=#


# Notebooks interativos 
# binder: https://mybinder.org 
# https://mybinder.org/v2/gh/ASaragga/GRF.jl/HEAD
#           
# nbviewer: https://nbviewer.jupyter.org
# https://github.com/ASaragga/GRF.jl/blob/master/src/Modulo1.1-1.7.ipynb



end # module
