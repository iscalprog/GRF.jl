module GRF

using ARCHModels        # Modelos GARCH
using Cbc               # Optimização com variáveis discretas
using CSV
using Dates             # Operações com datas
using DataFrames
using Distributions     # Distribuições de probabilidade
using HypothesisTests   # Testes de hipóteses
using HTTP
using Ipopt             # Optimização não-linear
using JSON
using JuMP              # Linguagem de modelização para optimização
using Juniper           # Optimização não-linear com variáveis discretas
using LinearAlgebra     #
using Random            # 
using Statistics        # Estatística descritiva, inclui cálculo de quantis
using StatsPlots        # Gráficos 

include("modulo01.jl")

# using Pkg
# println(haskey(Pkg.installed(), "JuMP"))


# Notebooks interativos 
# binder: https://mybinder.org 
# https://mybinder.org/v2/gh/ASaragga/GRF.jl/HEAD
#           
# nbviewer: https://nbviewer.jupyter.org
# https://github.com/ASaragga/GRF.jl/blob/master/src/Modulo1.1-1.7.ipynb



end # module
