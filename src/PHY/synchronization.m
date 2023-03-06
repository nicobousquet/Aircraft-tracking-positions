function r_l = synchronization(s_l, f_se, Te, variance_nl)
    p1 = ones(1, f_se/2);
    p2 = zeros(1, f_se/2);
    s_p = [p1 p2 p1 p2 p2 p2 p2 p1 p2 p1 p2 p2 p2 p2 p2 p2]; %on crée le préambule
    s_l = [s_p s_l]; %on rajoute le préambule 

    delta_t = randi([0, 100]); %retard temporel=delta*Te
    dirac = zeros(1, delta_t+1);
    dirac(delta_t + 1) = 1;
    delta_f = randi([-1e3, 1e3]);
    s_l = conv(s_l, dirac); %on ajoute un retard temporel
    t = 0:Te:length(s_l)*Te-Te;
    s_l = s_l.*exp(-1i*2*pi*delta_f*t);

    n_l = sqrt(variance_nl)*(randn(size(s_l)));
    y_l = s_l+n_l;
    r_l = abs(y_l).^2;
    s_p_bis = [zeros(1, length(r_l)-length(s_p)) s_p]; %on met s_p à la même taille que r_l pour la corrélation
    intercorr = xcorr(r_l, s_p_bis);
    intercorr = intercorr(length(s_p):length(r_l));

    porte = ones(1, length(s_p));
    liste = conv(abs(r_l').^2, porte, 'valid');

    denom = sqrt(sum(abs(s_p).^2)).*sqrt(liste);
    rho = intercorr'./(denom);

    %index = find(rho>0.6);

    [argvalue, argmax] = max(rho(1:101));
    delay = argmax-1;
    r_l = r_l(delay+length(s_p)+1:length(r_l)); %on enlève le retard
end