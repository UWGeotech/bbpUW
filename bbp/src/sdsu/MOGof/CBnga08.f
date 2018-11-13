C --------------------------CB_2008_NGA------------------------------------
C -------------------------------------------------------------------------
C by Yoshifumi Yamamoto, 11/10/08
C Stanford University
C yama4423@stanford.edu
C
C Campbell-Bozorgnia attenuation equation, 2008
C
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C Input Variables
C M             = Magnitude
C T             = Period (sec); Use -1 for PGV computation and -10 for PGD
C                 computation
C                 Use 1000 for output the array of Sa with period
C Rrup          = Closest distance coseismic rupture (km)
C Rjb           = Joyner-Boore distance (km)
C Ztor          = Depth to the top of coseismic rupture (km)
C delta         = average dip of the rupture place (degree)
C lambda        = rake angle (degree)
C Vs30          = shear wave velocity averaged over top 30 m (m/s)
C Zvs           = Depth to the 2.5 km/s shear-wave velocity horizon (km)
C arb           = 1 for arbitrary component sigma
C               = 0 for average component sigma
C
C Output Variables
C Sa            = Median spectral acceleration prediction
C sigma         = logarithmic standard deviation of spectral acceleration
C                 prediction
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C--------------------------------------------------------------------------
C Any interpretation between defined periods must be done externally
C--------------------------------------------------------------------------
      subroutine CB_2008_NGA(M, T, Rjb, Rrup, Ztor, Zvs, Vs, lambda, 
     +                       delta, arb, y, sigma)
      implicit none
      integer             :: L1, arb, i, j
      real                :: c, n, M, T, Rjb, Rrup, Ztor, Zvs, Vs
      real                :: delta, y, sigma, fmag, fdis, ffltz, fhngm
      real                :: fhngr, fhng, fhngz, fhngdelta, fsite
      real                :: fflt, fsed, tau_sq, sigma_sq, slnaf
      real                :: A1100, Frv, Fnm, lambda, alpha1, slnpga
      real                :: slnab, slnyb, sigmat, tau
      parameter(L1=24)
      real, dimension(L1) :: period,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9
      real, dimension(L1) :: c10, c11, c12, k1, k2, k3, slny, tlny, rhos
      real, dimension(L1) :: rhot, sigmac
C--------------------------------------------------------------------------
C---------------------Start Coeff Definition-------------------------------
C--------------------------------------------------------------------------
      data period/.01,.02,.03,.05,.075,.1,.15,.2,.25,.3,.4,.5,.75,
     +1,1.5,2,3,4,5,7.5,10,0,-1,-10/
      data c0/-1.715,-1.68,-1.552,-1.209,-0.657,-0.314,-0.133,-0.486,
     +-0.89,-1.171,-1.466,-2.569,-4.844,-6.406,-8.692,-9.701,-10.556,
     +-11.212,-11.684,-12.505,-13.087,-1.715,0.954,-5.27/

      data c1/.5,.5,.5,.5,.5,.5,.5,.5,.5,.5,.5,.656,.972,
     +1.196,1.513,1.6,1.6,1.6,1.6,1.6,1.6,.5,.696,1.6/

      data c2/-0.53,-0.53,-0.53,-0.53,-0.53,-0.53,-0.53,-0.446,-0.362,
     +-0.294,-0.186,-0.304,-0.578,-0.772,-1.046,-0.978,-0.638,
     +-0.316,-0.07,-0.07,-0.07,-0.53,-0.309,-0.07/

      data c3/-0.262,-0.262,-0.262,-0.267,-0.302,-0.324,-0.339,-0.398,
     +-0.458,-0.511,-0.592,-0.536,-0.406,-0.314,-0.185,-0.236,
     +-0.491,-0.77,-0.986,-0.656,-0.422,-0.262,-0.019,0/

      data c4/-2.118,-2.123,-2.145,-2.199,-2.277,-2.318,-2.309,-2.22,
     +-2.146,-2.095,-2.066,-2.041,-2,-2,-2,-2,-2,-2,-2,-2,-2,
     +-2.118,-2.016,-2/

      data c5/0.17,0.17,0.17,0.17,0.17,0.17,0.17,0.17,0.17,0.17,0.17,
     +0.17,0.17,0.17,0.17,0.17,0.17,0.17,0.17,0.17,0.17,0.17,0.17,
     +0.17/

      data c6/5.6,5.6,5.6,5.74,7.09,8.05,8.79,7.6,6.58,6.04,5.3,4.73,4,
     +4,4,4,4,4,4,4,4,5.6,4,4/

      data c7/0.28,0.28,0.28,0.28,0.28,0.28,0.28,0.28,0.28,0.28,0.28,0.28
     +,0.28,0.255,0.161,0.094,0,0,0,0,0,0.28,0.245,0/

      data c8/-0.12,-0.12,-0.12,-0.12,-0.12,-0.099,-0.048,-0.012,0,0,0,
     +0,0,0,0,0,0,0,0,0,0,-0.12,0,0/

      data c9/0.49,0.49,0.49,0.49,0.49,0.49,0.49,0.49,0.49,0.49,0.49,
     +0.49,0.49,0.49,0.49,0.371,0.154,0,0,0,0,0.49,0.358,0/

      data c10/1.058,1.102,1.174,1.272,1.438,1.604,1.928,2.194,2.351,
     +2.46,2.587,2.544,2.133,1.571,0.406,-0.456,-0.82,-0.82,-0.82,
     +-0.82,-0.82,1.058,1.694,-0.82/
      data c11/0.04,0.04,0.04,0.04,0.04,0.04,0.04,0.04,0.04,0.04,0.04,
     +0.04,0.077,0.15,0.253,0.3,0.3,0.3,0.3,0.3,0.3,0.04,0.092,0.3/
      data c12/0.61,0.61,0.61,0.61,0.61,0.61,0.61,0.61,0.61,0.61,
     +0.61,0.883,1,1,1,1,1,1,1,1,1,0.61,1,1/
C--------------------------------------------------------------------------
      data k1/865,865,908,1054,1086,1032,878,748,654,587,503,457,410,
     +400,400,400,400,400,400,400,400,865,400,400/
      data k2/-1.186,-1.219,-1.273,-1.346,-1.471,-1.624,-1.931,-2.188,
     +-2.381,-2.518,-2.657,-2.669,-2.401,-1.955,-1.025,-0.299, 
     +0,0,0,0,0,-1.186,-1.955,0/
      data k3/1.839,1.84,1.841,1.843,1.845,1.847,1.852,1.856,
     +1.861,1.865,1.874,1.883,1.906,1.929,1.974,2.019,2.11,2.2,
     +2.291,2.517,2.744,1.839,1.929,2.744/
C--------------------------------------------------------------------------
      data slny/0.478,0.48,0.489,0.51,0.52,0.531,0.532,0.534,0.534,
     +0.544,0.541,0.55,0.568,0.568,0.564,0.571,0.558,0.576,0.601,
     +0.628,0.667,0.478,0.484,0.667/
      data tlny/0.219,0.219,0.235,0.258,0.292,0.286,0.28,0.249,0.24,
     +0.215,0.217,0.214,0.227,0.255,0.296,0.296,0.326,0.297,
     +0.359,0.428,0.485,0.219,0.203,0.485/
      data sigmac/0.166,0.166,0.165,0.162,0.158,0.17,0.18,0.186,
     +0.191,0.198,0.206,0.208,0.221,0.225,0.222,0.226,0.229,
     +0.237,0.237,0.271,0.29,0.166,0.19,0.29/
      data rhos/1,0.999,0.989,0.963,0.922,0.898,0.89,0.871,0.852,
     +0.831,0.785,0.735,0.628,0.534,0.411,0.331,0.289,0.261,0.2,
     +0.174,0.174,1,0.691,0.174/
      data rhot/1,0.994,0.979,0.927,0.88,0.871,0.885,0.913,0.873,
     +0.848,0.756,0.631,0.442,0.29,0.29,0.29,0.29,0.29,0.29,0.29,
     +0.29,1.0,0.538,0.29/


      data c,n/1.88,1.18/
C--------------------------------------------------------------------------
C---------------------End Coeff Definition---------------------------------
C--------------------------------------------------------------------------
      i=0
      do 1000 j=1,L1
         if(INT(period(j)*1000) .eq. INT(1000*T)) i=j
 1000 continue
C--------------------------------------------------------------------------
C--------------------------Magnitude Dependence----------------------------
C--------------------------------------------------------------------------
      if(M .le. 5.5) then
          fmag = c0(i)+c1(i)*M
      else
          if(M .le. 6.5) then
              fmag = c0(i)+c1(i)*M+c2(i)*(M-5.5)
          else    
              fmag = c0(i)+c1(i)*M+c2(i)*(M-5.5)+c3(i)*(M-6.5)
          endif
      endif
C--------------------------------------------------------------------------
C--------------------------Distance Dependence-----------------------------
C--------------------------------------------------------------------------
      fdis = (c4(i)+c5(i)*M)*log(sqrt(Rrup**2 + c6(i)**2))
C--------------------------------------------------------------------------
C--------------------------Style of faulting-------------------------------
C--------------------------------------------------------------------------
      if(Ztor .lt. 1) then
          ffltz = Ztor
      else    
          ffltz = 1.0
      endif

      if(lambda .gt. 30 .AND. lambda .lt. 150) then
         fflt = c7(i) *  ffltz
      elseif(lambda .gt. -150 .AND. lambda .lt. -30) then
         fflt = c8(i)
      else
         fflt = 0.0
      endif
C--------------------------------------------------------------------------
C--------------------------Hanging-wall effects----------------------------
C--------------------------------------------------------------------------
      if(Rjb .eq. 0.0) then
          fhngr = 1.0
      else    
          if(Ztor .lt. 1.0) then
              if(Rrup .ge. sqrt(Rjb**2+1)) then
                fhngr = (Rrup-Rjb)/Rrup
              else
                fhngr = (sqrt(Rjb**2+1)-Rjb)/(sqrt(Rjb**2+1))
              endif
          else    
              fhngr = (Rrup - Rjb)/Rrup
          endif
      endif 
C--------------------------------------------------------------------------
C--------------------------Magnitude Dependence----------------------------
C--------------------------------------------------------------------------
      if(M .le. 6.0) then
          fhngm = 0.0
      elseif(M .lt. 6.5) then
          fhngm = 2.0 * (M - 6.0)
      else    
          fhngm = 1.0
      endif

      if(Ztor .ge. 0.0 .AND. Ztor .lt. 20.0) then
          fhngz = ((20.0-Ztor)/20.0)
      else
          fhngz = 0.0
      endif

      if(delta .le. 70.0) then
          fhngdelta = 1.0
      else
          fhngdelta = ((90.0-delta)/20.0)
      endif

      fhng = c9(i) * fhngr * fhngm * fhngz * fhngdelta
C--------------------------------------------------------------------------
C--------------------------Site conditions---------------------------------
C--------------------------------------------------------------------------
      if(Vs .lt. k1(i)) then
          call CB_2008_A1100 (M, Rjb, Rrup, Ztor, Zvs, lambda, delta, 
     +                        arb, A1100)
          fsite = c10(i)*log(Vs/k1(i))+k2(i)*(log(A1100+c*(Vs/k1(i))**n)
     +            -log(A1100+c))
      elseif(Vs .gt. 1100) then
          fsite = (c10(i)+k2(i)*n)*log(1100/k1(i))
      else    
          fsite = (c10(i)+k2(i)*n)*log(Vs/k1(i))
      endif
C--------------------------------------------------------------------------
C--------------------------Sediment effects--------------------------------
C--------------------------------------------------------------------------
      if(Zvs .lt. 1.0) then
          fsed = c11(i)*(Zvs-1)
      else
          if(Zvs .le. 3.0) then
              fsed = 0
          else    
              fsed = c12(i)*k3(i)*exp(-0.75)*(1-exp(-0.25*(Zvs-3)))
          endif
      endif 
C--------------------------------------------------------------------------
C--------------------------Median value------------------------------------
C--------------------------------------------------------------------------
      y = exp(fmag+fdis+fflt+fhng+fsite+fsed)
C--------------------------------------------------------------------------
C-------------------Standard deviation computations------------------------
C--------------------------------------------------------------------------
      if (Vs .lt. k1(i)) then
          alpha1 = k2(i)*A1100*((A1100+c*(Vs/k1(i))**n)**(-1)
     +             -(A1100+c)**(-1))
      else
          alpha1 = 0.0
      endif
C------------------------------------------------------------------------    
C      sigma_sq = slny(i)**2+alpha1**2*slny(22)**2+2*alpha1*rhos(i)*
C     +           slny(i)*slny(22)
C      tau_sq = tlny(i)**2+alpha1**2*tlny(22)**2+2*alpha1*rhot(i)*tlny(i)
C     +         *tlny(22)
C    
C      if(arb .eq. 1) then
C          sigma = sqrt(sigma_sq + tau_sq + sigmac(i)**2)
C      else
C          sigma = sqrt(sigma_sq + tau_sq)
C      endif
C--------------------------------------------------------------------------
      slnaf=0.3
      slnpga=slny(22)
      slnab=sqrt(slnpga**2  - slnaf**2)
      slnyb=sqrt(slny(i)**2 - slnaf**2)
      sigmat = sqrt(slny(i)**2 + alpha1**2*slnab**2 + 
     +         2*alpha1*rhos(i)*slnyb*slnab)
      tau = tlny(i)

      sigma=sqrt(sigmat**2 + tau**2)
      if(arb .EQ. 1) then
          sigma = sqrt(sigma**2 + sigmac(i)**2)
      endif

C--------------------------------------------------------------------------
C--------------------------------------------------------------------------
C--------------------------------------------------------------------------
      end subroutine CB_2008_NGA
C -------------------------------------------------------------------------
C --------------------------CB_2008_A1100----------------------------------
C -------------------------------------------------------------------------
      subroutine CB_2008_A1100(M, Rjb, Rrup, Ztor, Zvs, lambda, delta,
     +                         arb, y)
      implicit none
      integer       :: L1, arb, i, j
      real          :: c, n, M, Rjb, Rrup, Ztor, Zvs, Vs, lambda
      real          :: delta, y, sigma, fmag, fdis, ffltz, fhngm
      real          :: fhngr, fhng, fhngz, fhngdelta, fsite
      real          :: fflt, fsed, tau_sq, sigma_sq, sigmac, alpha1
      real          :: A1100, Frv, Fnm, T
      real          :: c0, c1, c2, c3, c4, c5, c6, c7, c8, c9
      real          :: c10, c11, c12, k1, k2, k3, slny, tlny, rhos
      real          :: rhot
      parameter(L1=24, T=0, Vs=1100)
C--------------------------------------------------------------------------
C---------------------Start Coeff Definition-------------------------------
C--------------------------------------------------------------------------
      data c0, c1,c2,c3,c4,c5/-1.715,0.5,-0.53,-0.262,-2.118,0.17/
      data c6/5.6/, c7/0.28/, c8/-0.12/, c9/0.49/, c10/1.058/, c11/0.04/
      data c12/0.61/
C--------------------------------------------------------------------------
      data k1/865/, k2/-1.186/, k3/1.839/
C--------------------------------------------------------------------------
      data slny/0.478/, tlny/0.219/, sigmac/0.166/, rhos/1/, rhot/1/
      data c,n/1.88,1.18/
C--------------------------------------------------------------------------
C--------------------------End Coeff Definition----------------------------
C--------------------------------------------------------------------------
C--------------------------Magnitude Dependence----------------------------
C--------------------------------------------------------------------------
      if(M .le. 5.5) then
          fmag = c0+c1*M
      else
          if(M .le. 6.5) then
              fmag = c0+c1*M+c2*(M-5.5)
          else    
              fmag = c0+c1*M+c2*(M-5.5)+c3*(M-6.5)
          endif
      endif
C--------------------------------------------------------------------------
C--------------------------Distance Dependence-----------------------------
C--------------------------------------------------------------------------
      fdis = (c4+c5*M)*log(sqrt(Rrup**2 + c6**2))
C--------------------------------------------------------------------------
C--------------------------Style of faulting-------------------------------
C--------------------------------------------------------------------------
      if(Ztor .lt. 1) then
          ffltz = Ztor
      else    
          ffltz = 1.0
      endif

      if(lambda .gt. 30 .AND. lambda .lt. 150) then
         fflt = c7 *  ffltz
      elseif(lambda .gt. -150 .AND. lambda .lt. -30) then
         fflt = c8
      else
         fflt = 0.0
      endif
C--------------------------------------------------------------------------
C--------------------------Hanging-wall effects----------------------------
C--------------------------------------------------------------------------
      if(Rjb .eq. 0.0) then
          fhngr = 1.0
      else    
          if(Ztor .lt. 1.0) then
              if(Rrup .ge. sqrt(Rjb**2+1)) then
                fhngr = (Rrup-Rjb)/Rrup
              else
                fhngr = (sqrt(Rjb**2+1)-Rjb)/(sqrt(Rjb**2+1))
              endif
          else    
              fhngr = (Rrup - Rjb)/Rrup
          endif
      endif 
C--------------------------------------------------------------------------
C--------------------------Magnitude Dependence----------------------------
C--------------------------------------------------------------------------
      if(M .le. 6.0) then
          fhngm = 0.0
      else
          if(M .lt. 6.5) then
              fhngm = 2.0 * (M - 6.0)
          else    
              fhngm = 1.0
          endif
      endif

      if(Ztor .ge. 0.0 .AND. Ztor .lt. 20.0) then
          fhngz = ((20.0-Ztor)/20.0)
      else
          fhngz = 0.0
      endif

      if(delta .le. 70.0) then
          fhngdelta = 1
      else
          fhngdelta = ((90.0-delta)/20.0)
      endif

      fhng = c9 * fhngr * fhngm * fhngz * fhngdelta
C--------------------------------------------------------------------------
C--------------------------Site conditions---------------------------------
C--------------------------------------------------------------------------
          fsite = (c10+k2*n)*log(Vs/k1);
C--------------------------------------------------------------------------
C--------------------------Sediment effects--------------------------------
C--------------------------------------------------------------------------
      if(Zvs .lt. 1.0) then
          fsed = c11*(Zvs-1)
      else
          if(Zvs .le. 3.0) then
              fsed = 0
          else    
              fsed = c12*k3*exp(-0.75)*(1-exp(-0.25*(Zvs-3)))
          endif
      endif 
C--------------------------------------------------------------------------
C--------------------------Median value------------------------------------
C--------------------------------------------------------------------------
      y = exp(fmag+fdis+fflt+fhng+fsite+fsed)
C--------------------------------------------------------------------------
C--------------------------------------------------------------------------
C--------------------------------------------------------------------------
      end subroutine CB_2008_A1100