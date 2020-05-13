function [Bout, resid, SSR] = marquardtTESTE(B, p, d, q, y_antigo)
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here
    
    h = ones(length(B),1);                                                  % vector-coluna com PASSO DE CORREC��O a somar em cada optimiza��o dos pesos/coeficientes - ATEN��O!!! O h N�O TEM VALORES DIFERENTES?
    
    SSR = [];                                                               % vector-coluna que vai guardar todos as Sum of Squared Residuals calculadas
    
    tolerancia = 0.001;                                                     % valor m�ximo de 'h' que j� se aceita como converg�ncia
    maxIter = 100;                                                          % n� m�ximo de itera��es aceites para o algoritmo
    iteracao = 1;
    
    while h > tolerancia && iteracao < maxIter
        
        %% C�LCULO DOS RES�DUOS PARA OS VALORES DE TREINO, FACE AOS COEFICIENTES PREDEFINIDOS
        
        resid = ValuesResidues(B, p, d, q, y_antigo);                       % vector-coluna com os res�duos entre os valores de treino reais e o modelo ajustado com os coeficientes existentes
        
        %% C�LCULO DE SSR (SUM OF SQUARE RESIDUALS)
        
        SQRresid = resid.^2;                                                % vector-coluna com cada valor de res�duo elevado ao quadrado
        SSR(iteracao,1) = sum(SQRresid);                                    % soma de todos os quadrados dos res�duos, com valor guardado no vector-coluna SSR
        
        %% C�LCULO DO PASSO 'h'
        
        B_interno = B + 0.01;                                               % cria-se um vector-coluna 'B_interno' com um incremento nos coefs proposto na p�g.217 do "Forecasting with UBJ Models", Alan Pankratz
        
        resid_interno = ValuesResidues(B_interno, p, d, q, y_antigo);       % vector-coluna com os res�duos calculados para esse vector 'B_interno'
        
        derivada = resid - resid_interno;                                   % vector-coluna com a diferen�a entre os dois vectores-coluna de res�duos, que corresponde a uma deriva��o parcial que entrar� na equa��o de obten��o de 'h', funcionando como 'vari�vel independente'
        
        % O c�lculo de 'h' segue a f�rmula:
        % resid = -1 . derivada . h + a , com a='res�duos da f�rmula que s�o minimizados', na p�g.216 do "Forecasting with UBJ Models", Alan Pankratz
        % Assim, segue a forma:
        % b = A . x
        %
        % 'h' dever� ser calculado atrav�s do m�todo de Least Linear Squares (LLS), com a express�o:
        
        A = diag(-1 * derivada);                                            % o vector 'derivada' tem de ser expresso em forma de matriz diagonal
        h = inv((A')*A) * (A') * resid;                                     % equa��o normal do m�todo LLS, para melhor estimativa de 'h', na p�g.256 do livro "Time Series Analysis: Forecasting and Control", Box, Jenkins
        
        % 'h' (calculado em cima) ser� vector-coluna com tantos elementos,
        % POIS, H� AQUI UM PROBLEMA!!!
        
        % VER ARTIGO MARQUARDT E CENA DE corrcoef DO MATLAB
        
        
        
        iteracao = iteracao + 1;
    end
    
end

