function [sumAR, Dcoefs] = ARparcelas(y, B, p, d)
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here
    
    % baseado nas p�gs.96-99, "Forecasting with UBJ Models", Alan Pankratz
    
    
    % CASO DE d=0
    if d==0                                                                 % neste caso, 'valores de w' = 'valores de y'
        
        Dcoefs = 0;
        
        if p ~= 0 && isempty(y) ~= 1
            if length(y) > p
                w = y(end:-1:(length(y)-p+1) ,1)';                              % 'w' � vector-linha apresentado por ordem crescente de lags: w(1)=w(t-1), w(2)=w(t-2), ...
            else
                w = [flip(y,1); zeros(p-length(y),1)]';                                 % caso p>length(y), preciso de mais lags, do que os valores de treino dispon�veis, ent�o coloco esses elementos como zero
            end                                                                 % caso p=length(y), o vector de zeros n�o � criado, pq fica com n� de linhas nulo
            sumAR = w * B(1:p,1);                                           % B(1:p,1) = ARcoefs, como est� definido na fun��o principal (ARIMAteste1)
        else
            sumAR = 0;
        end
        
        
    % CASO DE d~=0
    else
        
        % CRIAR VECTOR COM COEFS. DO POLIN�MIO INTRODUZIDO POR 'd'
        
        Dcoefs1 = [1; -1];                                                  % vector-coluna correspondente aos coefs. do polin�mio, para d=1
        Dcoefs = Dcoefs1;
        
        for a=2:1:d                                                         % s� entra no ciclo, caso d>=2
            
            Dcoefs = ones(a+1,1);                                           % 1� coef. de todos os polin�mios � 1, ent�o inicio o vector como sendo vector de 1's. 'Dcoefs' � vector-coluna
            
            for b=2:1: round((a+1)/2)                                       % ciclo que vai calcular os coefs. at� metade (ou metade+1, caso o n� de coeficientes, a+1, seja �mpar) do polin�mio/vector
                
                Dcoefs(b,1) = abs(Dcoefs1(b-1,1)) + abs(Dcoefs1(b,1));      % cada vector 'Dcoefs', para determinado 'd=a', � calculado a partir do vector 'Dcoefs' anterior ('Dcoefs1'), para 'd=a-1'
                
                if b/2 == round(b/2)                                        % os valores de 'Dcoefs' com �ndice par s�o negativos
                    Dcoefs(b,1) = -1* Dcoefs(b,1);
                end
            end
            
            espelho = 1;
            
            for c= a+1 :-1: round((a+1)/2)+1                                % ciclo que vai determinar os coefs. da restante metade do polin�mio/vector
                Dcoefs(c,1) = Dcoefs(espelho,1);                            % 'Dcoefs' � sim�trico em rela��o ao seu centro, se apenas contarmos com o valor absoluto de cada elemento
                espelho = espelho + 1;
            end
            
            if (a+1)/2 == round((a+1)/2)                                    % caso 'length(Dcoefs)=a+1' seja par, os "valores-espelho" calculados anteriormente s�o sim�tricos dos seus "originais"
                for d= a+1 :-1: round((a+1)/2)+1
                    Dcoefs(d,1) = -1* Dcoefs(d,1);
                end
            end
            
            Dcoefs1 = Dcoefs;
        end
        
        % AQUI, CADA 'w(t-i)' ESTAR� DEPENDENTE DE 'p' e 'd'!!!
        
        w = zeros(1,p);                                                     % vector-linha que vai armazenar todos os valores w(1)=w(t-1), w(2)=w(t-2), ..., por ordem crescente de lags
        
        % CRIAR VECTOR COM VALORES DE y UTILIZADOS NO POLIN�MIO
        
        if (p ~= 0) && (isempty(y) ~= 1)
            
            for iter=1:1:p
                
                if length(y) > iter+d
                    wy = y(end-iter+1 :-1: length(y)-iter-d+1,1)';    % vector-linha 'wy' vai incluir valores de 'y', da lag 'p=iter' at� � lag 'p+d=iter+d', por ordem crescente de lags
                elseif length(y) < iter
                    wy = zeros(1,d+1);
                else
                    wy = [y(end-iter+1 :-1: 1,1); zeros(iter+d-length(y) ,1)]';
                end
                w(1,iter) = wy*Dcoefs;                                      % vector 'w' final servir� para multiplicar pelo vector 'ARcoefs', resultando no somat�rio de termos AR() da regress�o ARIMA produzida
            end
            
            sumAR = w * B(1:p,1);                                           % B(1:p,1) = ARcoefs, como est� definido na fun��o principal (ARIMAteste1)
        else
            sumAR = 0;
        end
    end
end

