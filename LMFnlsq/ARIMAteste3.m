function [ y_past, y_predict, ARcoefs, MAcoefs, C ] = ARIMAteste3( p, d, q, y_antigo, numPrev )
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here
    
    if p > length(y_antigo) || q > length(y_antigo) || p<0 || q<0 || d<0 || nargin ~= 5
        disp('Imposs�vel de calcular, erro de input!')
        y_past = y_antigo; y_predict = []; ARcoefs = []; MAcoefs = [];
        
    else
        %% COLOCAR y_antigo COMO VECTOR-COLUNA
        if size(y_antigo,2) ~= 1
            y_antigo = y_antigo';
        end
        
        %%
        % ISOLAR DATASET INICIAL
        y_past = y_antigo;
        
        % COLOCAR DATASET COM M�DIA NULA, PARA TRABALHAR
        y = y_antigo - mean(y_antigo);                                                       % ISTO PODE PRECISAR DE MAIS TRANSFORMA��ES - PROCESSAMENTO!!! - ATEN��O, PODE SER NECESS�RIO METER M�DIA NULA!!!
        
        %%
        % C�LCULO DA AUTOCORRELA��O PARCIAL (PACF) E SIMPLES (ACF)
        
        PACFtotal = parcorr(y_past);                                        % vector-coluna com todos os valores de PACF dos dados de treino, relativamente ao 1� valor do dataset
        ACFtotal = autocorr(y_past);                                        % vector-coluna com todos os valores de ACF dos dados de treino, relativamente ao 1� valor do dataset
        
        %%
        % DETERMINA��O DOS VALORES INICIAIS PARA OS COEFICIENTES AR()
        
        if p ~= 0
            
            PACFar = PACFtotal(1:p+1);                                      % vector-coluna com os valores de PACF que importam para o c�lculo dos coeficientes AR (depende do valor 'p' escolhido)
            
            A = eye(p,p);                                                   % matriz A das equa��es de Yule-Walker, vai armazenar valores de PACF na ordem pretendida
            
            for l = 1:1:p
                for c = 1:1:p
                    A(l,c) = PACFar( abs(l-c)+1 );
                end
            end
            
            % C�LCULO DOS COEFICIENTES AR (FI)
            
            ARcoefs = (inv(A)) * PACFar(2:end);                             % vector-linha coefs AR, pelas equa��es de Yule-Walker. N�o se conta com PACF(1) pq � correla��o de y(0) consigo pr�prio (ou seja, 1)
            
            % C�LCULO DA VARI�NCIA ASSOCIADA AOS COEFS AR - ainda n�o percebi se serve para algo, sem ser diagn�stico...
            
            variancia=0;
            for i=1:1:length(ARcoefs)
                variancia = variancia + ARcoefs(i)*PACFar(i);
            end
            
            % C�LCULO DA ORDENADA ASSOCIADA � PARTE AR (MIU)
            
            miu = mean(y_past) * (1 - sum(ARcoefs));                        % ATEN��O A ISTO! PODE SER PRECISO MUDAR (METER DADOS COM M�DIA NULA, P.EX.)
            
            % Aten��o: n�o sei se est� bem calculado... A f�rmula �:
            % miu= MEAN *( 1 - sum(ARcoefs) )
            % MEAN= 'mean of differenced series'
            
        elseif p == 0
            ARcoefs = [];
            miu = mean(y_past);                                             % ATEN��O! VER BEM ISTO DO MIU!
        end
        
        %%
        % DETERMINA��O DOS VALORES INICIAIS PARA OS COEFICIENTES MA()
        
        if q ~= 0
            
            % C�LCULO DOS COEFICIENTES MA (TETA)
            
            if q==1 || q==2
                MAcoefs = -1* ACFtotal(2:q+1);                              % Aplicando o sugerido na p�g.307 do "Forecasting with UBJ Models", Alan Pankratz. Exclui-se ACF(1) pq � correla��o de y(0) consigo pr�prio
                
            else
                MAcoefs = 0.1* ones(q,1);
            end
            
        elseif q == 0
            MAcoefs = [];
        end
        
        %%
        % OPTIMIZA��O DOS COEFICIENTES AR() E/OU MA()
        
        if p~=0 || q~=0                                                     % estes coeficientes t�m de ser optimizados, para se adequarem aos dados de treino fornecidos. O m�todo utilizado (referido em baixo) est� sugerido nas p�gs.200/209 do "Forecasting with UBJ Models", Alan Pankratz
            
            B = [ARcoefs; MAcoefs];
            
            %
            %             [Bout, resid, SSR] = marquardtTESTE(B,p,d,q,y_antigo);          % Fun��o para aplicar o Marquadt's Compromise (ou Levenberg-Marquardt). � uma jun��o das vantagens do m�todo do gradiente descendente, com as vantagens do m�todo de Newton
            
            
            resid = ValuesResidues(B, p, d, q, y_antigo);
            
            t = 1:1:length(y_antigo)-2;
            
            res = @(B) -1*y_antigo(t+1) + B(1)*y_antigo(t) ;  %   anonym. funct. for residua
            
            [C,ssq,cnt] = LMFnlsq(res,B,'Display',-1);% without displ. lambda
            
            
            
            
        elseif p==0 && q==0
            % N�O ACONTECE NADA
        end
        
        %% FORMA FINAL - FORECAST
        
        y_predict = ARIMAforecast( ARcoefs, MAcoefs, p, d, q, y_antigo, resid, numPrev );
    end
end
