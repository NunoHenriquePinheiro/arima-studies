function [y_previsao, lowerConf95, upperConf95] = ARIMAforecast( B, p, d, q, y, resid, sigmahat, numPrev )
    %UNTITLED3 Summary of this function goes here
    %   Detailed explanation goes here
    
%     B = [ARcoefs; MAcoefs];
    
    yITERACAO = y;                                                          % vector-coluna que vai guardar todos os valores de y = [y_antigo (dados de treino), y_previsao (forecasts com os par�metros de regress�o pr�-existentes)]
    
    for a=1:1:numPrev                                                       % ciclo para calcular todas as previs�es
        
        %% C�LCULO DAS PARCELAS AR(), RELACIONADAS COM 'ARcoefs' E 'p'
        
%         if p ~= 0
%             
%             % C�LCULO DE w(t-1),...,w(t-p), CORRESPONDENTE AOS ARcoefs
            
        [sumAR, Dcoefs] = ARparcelas(yITERACAO, B, p, d);
            
%             w = zeros(1,p);                                                 % vector-linha (pq. coefs est�o em vector-coluna) que vai armazenar w(t-1),...,w(t-p), para t=a
%             
%             for b=1:1:p                                                     % c�lculo de 'w(t=a, b) = y(b) - y(b-d)'. Se os valores de 'y' n�o existirem, s�o entendidos como zero. Existem tantos w(), quanto o valor 'p', ou seja, quanto o n� de ARcoefs
%                 
%                 if length(yITERACAO) < b                                            % define-se o valor 'w1 = y(b)'
%                     w1 = 0;
%                 else
%                     w1 = yITERACAO(end-b+1,1);
%                 end
%                 
%                 if d ~= 0                                                   % o valor 'w2', calculado a seguir, s� pode ser obtido, quando 'd' n�o � nulo. As opera��es dentro desta cl�usula n�o podem existir quando d=0, pq, nessas condi��es, pela diferen�a 'w=w1-w2', iriam comprometer o c�lculo final
%                     if length(yITERACAO) < b+d                                      % define-se o valor 'w2 = y(b-d)'
%                         w2 = 0;
%                     else
%                         w2 = yITERACAO(end-b-d+1,1);
%                     end
%                 elseif d==0
%                     w2 = 0;
%                 end
%                 
%                 w(1,b) = w1 - w2;                                           % 'w(t=a, b) = y(b) - y_antigo(b-d)'
%             end                                                             % no fim do ciclo, o vector 'w' tem 'p' valores, para multiplicar matricialmente pelos 'p' valores do vector 'ARcoefs', necess�rio para calcular 1 elemento de 'y_esperado'. NOTA: 'w' e 'ARcoefs' est�o organizados por ordem crescente de lags, por facilitar os c�lculos! EX.: w(1)=w(t-1), w(2)=w(t-2), etc.
%             
%             % C�LCULO DA SOMA DAS PARCELAS AR()
%             
%             sumAR = w * B(1:p,1);                                           % B(1:p,1) = ARcoefs, como est� definido no in�cio
%         else
%             sumAR = 0;                                                      % se p=0, ent�o sumAR=0
%         end
        
        %% C�LCULO DAS PARCELAS MA(), RELACIONADAS COM 'MAcoefs' E 'q'
        
        if q ~= 0 && isempty(resid) ~= 1
            
            % DEFINI��O DOS RES�DUOS QUE ENTRAM NO C�LCULO
            
            if size(resid,1) ~= 1                                           % vector de res�duos tem de ser vector-linha
                resid = resid';
            end
            
            residANTIGOS = zeros(1,q-length(resid));                        % 'residANTIGOS' ter� os valores de res�duos n�o conhecidos assumidos como zero. Tamb�m � vector-linha.
            residANTIGOS = [flip(resid,2), residANTIGOS];                   % 'residANTIGOS' e 'MAcoefs' est�o organizados por ordem crescente de lags, por facilitar os c�lculos! EX.: residANTIGOS(1)=residANTIGOS(t-1), residANTIGOS(2)=residANTIGOS(t-2), etc.
%             residANTIGOS = [resid residANTIGOS];                            % 'residANTIGOS' e 'MAcoefs' est�o organizados por ordem crescente de lags, por facilitar os c�lculos! EX.: residANTIGOS(1)=residANTIGOS(t-1), residANTIGOS(2)=residANTIGOS(t-2), etc.
            
            if length(yITERACAO) > length(y)                                % se esta condi��o se verifica, � pq. j� foram feitas previs�es
                resid_forecast = zeros(1,length(yITERACAO)-length(y));
                residANTIGOS = [resid_forecast residANTIGOS];               % cada previs�o tem res�duo nulo, ent�o temos de preencher as lags mais recentes (correspondentes �s previs�es) com zeros
            end
            
            % C�LCULO DA SOMA DAS PARCELAS MA()
            
            sumMA = residANTIGOS(1,1:q) * B(p+1:end,1);                     % B(p+1:end,1) = MAcoefs, como est� definido no in�cio
        else
            sumMA = 0;
        end
        
        %% C�LCULO DAS PARCELAS I(), RELACIONADAS COM 'd'
        
        % NOTA: o valor de 'd' j� se reflecte no c�lculo de AR
        
        if d==0
            sumI = 0;
        elseif d ~= 0 && d <= length(yITERACAO)
            D1coefs = Dcoefs(2:end,1);
            sumI = yITERACAO(end:-1:end-d+1,1)' *D1coefs;
        else
            D1coefs = Dcoefs(2:end,1);
            sumI = [yITERACAO(end:-1:1,1)', zeros(1,d-length(yITERACAO))] *D1coefs;
        end
        
%         if d ~= 0 && d <= length(yITERACAO)
%             sumI = yITERACAO(end-d+1,1);
%         else
%             sumI = 0;
%         end
        
        %% C�LCULO DE y E DE resid
        
        valor1 = sumAR - sumI - sumMA;
        yITERACAO = [yITERACAO; valor1];                                                    % cada valor de 'y', no "instante seguinte", � adicionado ao vector-coluna 'y'
    end
    
    y_previsao = yITERACAO(length(y)+1:end,1);                              % 'y_previsao' � vector-coluna com todas as forecasts
    
    desvioPadrao = desvioARIMA(B, p, sigmahat, numPrev);           % calcula desvio-padr�o associado aos res�duos dos dados de treino, face ao modelo estimado
    
    lowerConf95 = y_previsao' - 1.96*desvioPadrao;                          % calcula limites de "Forecast Confidence Intervals" - de acordo com o sugerido nas p�gs.252-256 do livro "Forecasting with UBJ Models", Alan Pankratz
    upperConf95 = y_previsao' + 1.96*desvioPadrao;                          % neste caso, com confian�a de 95%
end

