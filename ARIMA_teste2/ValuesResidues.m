function resid = ValuesResidues(B, p, d, q, y)
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here
    
%     B = [ARcoefs; MAcoefs];
    
    y_esperado = [];                                                        % vector-coluna que vai guardar os valores esperados de y (dados de treino), segundo os par�metros de regress�o pr�-existentes
    resid = [];                                                             % vector-coluna que vai guardar todos os res�duos resultantes dos c�lculos: 'resid = y_antigo - y_esperado'
    
    for a=1:1:length(y)                                                     % ciclo para calcular todos os valores de 'y_esperado', correspondentes a 'y' (dados de treino)
        
        %% C�LCULO DAS PARCELAS AR(), RELACIONADAS COM 'ARcoefs' E 'p'
        
%         if p ~= 0 && isempty(y_esperado) ~= 1
%             
%             % C�LCULO DE w(t-1),...,w(t-p), CORRESPONDENTE AOS ARcoefs
            
        [sumAR, Dcoefs] = ARparcelas(y_esperado, B, p, d);
            
%             w = zeros(1,p);                                                 % vector-linha (pq. coefs est�o em vector-coluna) que vai armazenar w(t-1),...,w(t-p), para t=a
%             
%             for b=1:1:p                                                     % c�lculo de 'w(t=a, b) = y_esperado(b) - y_esperado(b-d)'. Se os valores de 'y_esperado' n�o existirem, s�o entendidos como zero. Existem tantos w(), quanto o valor 'p', ou seja, quanto o n� de ARcoefs
%                 
%                 if length(y_esperado) < b                                   % define-se o valor 'w1 = y_esperado(b)'
%                     w1 = 0;
%                 else
%                     w1 = y_esperado(end-b+1,1);
%                 end
%                 
%                 if d ~= 0                                                   % o valor 'w2', calculado a seguir, s� pode ser obtido, quando 'd' n�o � nulo. As opera��es dentro desta cl�usula n�o podem existir quando d=0, pq, nessas condi��es, pela diferen�a 'w=w1-w2', iriam comprometer o c�lculo final
%                     if length(y_esperado) < b+d                             % define-se o valor 'w2 = y_esperado(b-d)'
%                         w2 = 0;
%                     else
%                         w2 = y_esperado(end-b-d+1,1);
%                     end
%                 elseif d==0
%                     w2 = 0;
%                 end
%                 
%                 w(1,b) = w1 - w2;                                           % 'w(t=a, b) = y_esperado(b) - y_antigo(b-d)'
%             end                                                             % no fim do ciclo, o vector 'w' tem 'p' valores, para multiplicar matricialmente pelos 'p' valores do vector 'ARcoefs', necess�rio para calcular 1 elemento de 'y_esperado'. NOTA: 'w' e 'ARcoefs' est�o organizados por ordem crescente de lags, por facilitar os c�lculos! EX.: w(1)=w(t-1), w(2)=w(t-2), etc.
%             
%             % C�LCULO DA SOMA DAS PARCELAS AR()
%             
%             sumAR = w * B(1:p,1);                                           % B(1:p,1) = ARcoefs, como est� definido na fun��o principal (ARIMAteste1)
%         else
%             sumAR = 0;                                                      % se p=0, ent�o sumAR=0
%         end
        
        %% C�LCULO DAS PARCELAS MA(), RELACIONADAS COM 'MAcoefs' E 'q'
        
        if q ~= 0 && isempty(resid) ~= 1
            
            % DEFINI��O DOS RES�DUOS QUE ENTRAM NO C�LCULO
            
            residANTIGOS = zeros(1,q-length(resid));                        % 'residANTIGOS' ter� os valores de res�duos n�o conhecidos assumidos como zero
            residANTIGOS = [flip(resid',2), residANTIGOS];                  % 'residANTIGOS' e 'MAcoefs' est�o organizados por ordem crescente de lags, por facilitar os c�lculos! EX.: residANTIGOS(1)=residANTIGOS(t-1), residANTIGOS(2)=residANTIGOS(t-2), etc.
%             residANTIGOS = [resid' residANTIGOS];                           % 'residANTIGOS' e 'MAcoefs' est�o organizados por ordem crescente de lags, por facilitar os c�lculos! EX.: residANTIGOS(1)=residANTIGOS(t-1), residANTIGOS(2)=residANTIGOS(t-2), etc.
            
            % C�LCULO DA SOMA DAS PARCELAS MA()
            
            sumMA = residANTIGOS(1,1:q) * B(p+1:end,1);                       % B(p+1:end,1) = MAcoefs, como est� definido na fun��o principal (ARIMAteste1)
        else
            sumMA = 0;
        end
        
        %% C�LCULO DAS PARCELAS I(), RELACIONADAS, APENAS, COM 'd'
        
        % NOTA: o valor de 'd' j� se reflecte no c�lculo de AR, em
        % ARparcelas. O c�lculo de 'sumI' � an�logo ao c�lculo de 'w(1,iter)'
        
        if d==0 || isempty(y_esperado) == 1
            sumI = 0;
        elseif d ~= 0 && d <= length(y_esperado)
            D1coefs = Dcoefs(2:end,1);
            sumI = y_esperado(end:-1:end-d+1,1)' *D1coefs;
%             sumI = y_esperado(end-d+1,1);
        else
            D1coefs = Dcoefs(2:end,1);
            sumI = [y_esperado(end:-1:1,1)', zeros(1,d-length(y_esperado))] *D1coefs;
        end
        
        %% C�LCULO DE y_esperado E DE resid
        
        valor1 = sumAR - sumI - sumMA;
        y_esperado = [y_esperado; valor1];                                  % cada valor de 'y_esperado', no "instante seguinte", � adicionado ao vector-coluna 'y_esperado'
        
        valor2 = y(a,1) - y_esperado(a,1);
        resid = [resid; valor2];                                            % cada valor de 'resid', no "instante seguinte", � adicionado ao vector-coluna 'resid'. NOTA: 'resid() = y_antigo() - y_esperado()'
        
    end                                                                     % no fim do ciclo, teremos 3 vectores-coluna: 1.y_antigo: dados de treino reais; 2.y_esperado: valores esperados, segundo a regress�o, para os dados de treino; 3.resid: diferen�a entre cada valor real e cada valor esperado pela regress�o.
end

