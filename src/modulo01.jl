const DJ30n = [:AAPL, :AMGN, :AXP, :BA, :CAT, :CRM, :CSCO, :CVX, :DD, :DIS, :GS, :HD, :HON, :IBM, :INTC, :JNJ, :JPM, :KO, :MCD, :MMM, :MRK,:MSFT, :NKE, :PG, :TRV, :UNH, :V,  :VZ, :WBA, :WMT, "^DJI", "^GSPC"]

const PSI20n = ["ALTR.LS", "BCP.LS", "COR.LS", "CTT.LS", "EDP.LS", "EDPR.LS", "GALP.LS", "IBS.LS", "JMT.LS", "EGL.LS", "NBA.LS", "NOS.LS", "NVG.LS", "PHR.LS", "RAM.LS", "RENE.LS", "SEM.LS", "SON.LS", "PSI20.LS"]

const DIVn = ["AMZN", "BAC", "C", "F", "FB", "GOOG","MS", "NFLX", "PEP", "TSLA"]

const FXn = ["EURUSD=X", "EURGBP=X", "EURJPY=X", "EURCHF=X", "EURSEK=X", "EURDKK=X", "EURCAD=X", "EURAUD=X", "EURKRW=X", "HKD=X"]


"""
    yahoo(símbolo, data_inicial, data_final, intervalo)
Faz o download de (i) cotações de fecho ajustadas para ações (ii) valores de índices de ações e (iii) cotações de taxas de câmbio, através de Yahoo.Finance

## Argumentos
* `símbolo`: Símbolo de mercado, e.g. "AAPL", "IBM", "^GSPC"
* `data_inicial`: Data inicial de tipo Date/DateTime, e.g. Date(2019,12,20) ou DateTime(2019,12,20,8,30,0)
* `data_final`: Data final de tipo Date/DateTime, e.g. Date(2020,12,20) ou DateTime(2020,12,20,8,30,0)
* `intervalo`: Intervalo de amostragem, e.g. "1d" (por omissão), "1wk", "1mo", "3mo"
## Exemplos
```jldoctest
julia> yahoo("GOOG", Date(2018,12,26), Date(2020,12,20))
julia> yahoo("GOOG", Date(2018,12,26), Date(2020,12,20), "1wk")
```
"""
function yahoo(symbol, date1 = Date(1900,1,1), date2 = Date(Dates.now()), interval::String = "1d")
    if isa(symbol, String) == true
        nsymb = 1
    elseif isa(symbol, Symbol) == true 
        nsymb = 1
    else
        nsymb = length(symbol)
    end
    
    date1 = DateTime(date1)
    date2 = DateTime(date2)
    if date1 > date2
        date1, date2 = date2, date1
    end
    date2 = date2 +  Day(1)  # Yahoo.Finance não incui a data final no período da amostra, daí incrmentar 1 dia
    from = string(round(Int64, datetime2unix(date1)))
    to = string(round(Int64, datetime2unix(date2)))
    host = rand(["query1", "query2"])
    for i in 1:nsymb
        if nsymb == 1 && (isa(symbol, String) == true || isa(symbol, Symbol) == true) 
            symb = String(symbol)
        else
            symb = String(symbol[i])
        end
        println(symb)
        url = "https://$host.finance.yahoo.com/v7/finance/chart/$symb?&interval=$interval&period1=$from&period2=$to"
        response = HTTP.get(url, cookies = true)
        body = JSON.parse(String(response.body))["chart"]["result"][1]   
        # values = body["indicators"]["quote"][1]
        a = replace!(body["indicators"]["adjclose"][1]["adjclose"], nothing => missing)
        new = DataFrame(
            Time = Dates.Date.(unix2datetime.(body["timestamp"])),
            # Open = convert(Vector{Float64},values["open"]),
            # High =  convert(Vector{Float64},values["high"]),
            # Low = convert(Vector{Float64},values["low"]),
            # Close = convert(Vector{Float64},values["close"]),
            #AdjClose = convert(Vector{Float64},body["indicators"]["adjclose"][1]["adjclose"]),
            AdjClose = convert(Vector{Union{Missing, Float64}},a),
            # Volume = convert(Vector{Int64},values["volume"])
        )
    
        DataFrames.rename!(new,[:Data, Symbol(symb)])
        #DataFrames.deleterows!(new, isnothing.(new).Close)
        if i == 1
            global old = new
        else
            old = outerjoin(old, new, on = :Data)
        end
    end
    return old
end
yahoo(s::Vector{Symbol}, date1, date2, interval) = yahoo(String.(s), date1, date2, interval)
yahoo(s::Vector{Symbol}, date1, date2) = yahoo(String.(s), date1, date2, "1d")
yahoo(s::Vector{Symbol}, date1) = yahoo(String.(s), date1, Date(Dates.now()), "1d")
yahoo(s::Symbol, date1, date2, interval) = yahoo(String(s), date1, date2, interval)
yahoo(s::Symbol, date1, date2) = yahoo(String(s), date1, date2, "1d")
yahoo(s::Symbol, date1) = yahoo(String(s), date1, Date(Dates.now()), "1d")



function retornos(df::DataFrame, tipo_retorno::Symbol) 
    c = Matrix(df)
    
    cot = convert(Matrix{Union{Missing, Float64}},c[:,2:end])
    dt  = convert(Vector{Date}, c[:,1])
    nret = size(c,1) - 1
    ncol = size(c,2) - 1       
    
    ret   = Array{Union{Missing, Float64}}(undef, nret, ncol)  
    datas = Array{Date}(undef,nret)
    if tipo_retorno == :log
        for i = 1:nret
            ret[i,:] = log.(cot[i+1,:]./cot[i,:])
            datas[i] = dt[i+1] 
        end
    elseif tipo_retorno == :simples
        for i = 1:nret
            ret[i,:] = cot[i+1,:]./cot[i,:] .- 1.0
            datas[i] = dt[i+1]    
        end
    end
    d = DataFrame(Data = datas)
    nomes = names(df)
    popfirst!(nomes)   
    r = DataFrame(ret, Symbol.(nomes))
    
    return  hcat(d, r)
end


function ETL(retornos, alfa, V)
    nobs = length(retornos)
    corte = quantile(retornos, alfa)
    excedimentos = 0
    n_excedimentos = 0
    for i in 1:nobs
        if retornos[i] <= corte
            excedimentos += retornos[i]
            n_excedimentos += 1
        end
    end
    return - (excedimentos/n_excedimentos - mean(retornos)) * V
end


function EWMA(serie, lambda)
    m = length(serie)
    media = mean(serie)                 
    σ2 = 0
    for k in 1:m
        σ2 += (1-lambda)*lambda^(k-1) * (serie[end-k+1] - media)^2
    end
    return sqrt(σ2)                     
end


function exceções(retornos, alfa)
    nobs = lenght(retornos)
    excep = zeros(nobs)
    sigma = std(retornos)
    RaR = - sigma * quantile(Normal(0,1), alfa)
    for i in 1:nobs
        if retornos[i] <= -RaR
            excep[i] = 1
        end
    end
    return sum(excep)
end


function cvm(Sigma)
    n = size(Sigma,1)
    modelo = Model(Ipopt.Optimizer)
    @variable(modelo, w[1:n])                      
    @objective(modelo, Min, w' * Sigma * w) 
    @constraint(modelo, sum(w) == 1)        
    @constraint(modelo, w .>= 0)            
    optimize!(modelo)                       
    return value.(w)
end


function fe(mu, Sigma, mu_k)
    n = size(Sigma,1)
    modelo = Model(Ipopt.Optimizer)
    @variable(modelo, w[1:n])     
    @objective(modelo, Min, w' * Sigma * w)  
    @constraint(modelo, sum(w) == 1)  
    @constraint(modelo, w .>= 0)      
    @constraint(modelo, mu' * w >= mu_k)
    optimize!(modelo)                   
    return value.(w)                                 
  end



function gfe(mu, Sigma, alfa, T, V_0, ncarteiras = 10)
    modelo = Model(Ipopt.Optimizer)
    set_silent(modelo)    
    n = length(mu)                              
    @variable(modelo, w[1:n])                           
    @objective(modelo, Min, w' * Sigma * w)             
    @constraint(modelo, sum(w) == 1)                    
    @constraint(modelo, w .>= 0)                        
    optimize!(modelo)                                   
    w_CVM = value.(w)                                   
    z_alfa = quantile(Normal(0,1), alfa)
    VaR_k = zeros(ncarteiras)
    mu_k = zeros(ncarteiras)
    mu_CVM = mu' * w_CVM
    for i in 0:ncarteiras-1
        modelo = Model(Ipopt.Optimizer)
        set_silent(modelo)                                  
        @variable(modelo, w[1:n])                           
        @objective(modelo, Min, w' * Sigma * w)             
        @constraint(modelo, sum(w) == 1)                    
        @constraint(modelo, w .>= 0)                        
        mu_max = maximum(mu)
        incremento = (mu_max-mu_CVM)/(ncarteiras-1)
        mu_k[i+1] = mu_CVM + incremento * i
        @constraint(modelo, mu' * w >= mu_k[i+1])                
        optimize!(modelo)                                  
        w_k = value.(w)   
        VaR_k[i+1] = -z_alfa * sqrt(T) * sqrt(w_k' * Sigma * w_k) * V_0
    end
    aVaR = -z_alfa * sqrt(T) * sqrt.(diag(Sigma)) * V_0
    fig = plot(VaR_k,mu_k, xlabel = "VaR da Carteira (α = $(alfa))", ylabel = "Valor Esperado do Retorno da Carteira", label = "Fronteira Efficiente", xlim = (0, maximum(aVaR) * 1.1), ylim = (0, maximum(mu)*1.1), legend = :bottomright)
    fig = scatter!(aVaR, mu, label = "Ações")
    VaR_CVM = -z_alfa * sqrt(T) * sqrt(w_CVM' * Sigma * w_CVM) * V_0
    fig = scatter!([VaR_CVM], [mu_CVM], label = "Carteira VaR Mínimo")
    return fig
end

function alocações(mu, Sigma, alfa, lista, ncarteiras = 10)
    modelo = Model(Ipopt.Optimizer)
    set_silent(modelo)       
    n = length(mu)                           
    @variable(modelo, w[1:n])                           
    @objective(modelo, Min, w' * Sigma * w)             
    @constraint(modelo, sum(w) == 1)                    
    @constraint(modelo, w .>= 0)                        
    optimize!(modelo)                                   
    w_CVM = value.(w)                                   
    z_alfa = quantile(Normal(0,1), alfa)
    mu_k = zeros(ncarteiras)
    w_k = zeros(n,ncarteiras)
    mu_CVM = mu' * w_CVM
    for i in 0:ncarteiras-1
        modelo = Model(Ipopt.Optimizer)
        set_silent(modelo)                                  
        @variable(modelo, w[1:n])                           
        @objective(modelo, Min, w' * Sigma * w)             
        @constraint(modelo, sum(w) == 1)                    
        @constraint(modelo, w .>= 0)                        
        mu_max = maximum(mu)
        incremento = (mu_max-mu_CVM)/(ncarteiras-1)
        mu_k[i+1] = mu_CVM + incremento * i
        @constraint(modelo, mu' * w >= mu_k[i+1])                
        optimize!(modelo)                                  
        w_k[:,i+1] = value.(w)   
    end
    println(w_k)
    ticklabel = "P" .* string.(collect(1:ncarteiras))
    ticklabel[1] = "CVM"
    ticklabel[ncarteiras] = "CRM"
    fig = groupedbar(w_k', bar_position = :stack, bar_width=1.0, xlabel = "Carteiras", xticks=(1:ncarteiras, ticklabel), ylabel = "Alocação", label = permutedims(String.(lista)), legend = :bottomright)
    return fig
end


#=
function installedx()
    @warn "Pkg.installed() is deprecated"
    deps = dependencies()
    installs = Dict{String, VersionNumber}()
    for (uuid, dep) in deps
        dep.is_direct_dep || continue
        dep.version === nothing && continue
        installs[dep.name] = dep.version
    end
    return installs
end
=#