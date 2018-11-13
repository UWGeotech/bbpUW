      subroutine BA_2008_nga(M, T, Rjb, FType, Vs30, Sa, sigma)
      implicit none
      integer             :: i, ip, j, k, L1
      real                :: M, T, Rjb, Vs30, Sa, sigma, U, S, N, R
      real                :: Fm, Fd, rr, lny, Flin, bnl, deltax, deltay
      real                :: c, d, Fnl, Fs, pga4nl, pTemp
      character*10        :: FType
      parameter(L1 = 24)
      real, dimension(L1) :: period, e01, e02, e03, e04, e05, e06, e07
      real, dimension(L1) :: mh, c01, c02, c03, mref, rref, h, blin 
      real, dimension(L1) :: vref, b1, b2, v1, v2, a1
      real, dimension(L1) :: pga_low a2 sig1 sig2u sigtu sig2m sigtm

C---------------------------------------------------------------------
C by Yoshifumi Yamamoto, 11/10/08
C Stanford University
C yama4423@stanford.edu
C
C Boore and Atkinson attenuation equation, 2008
C
C---------------------------------------------------------------------
C Input Variables
C M = Magnitude
C T = Period (sec); Use Period = -1 for PGV computation
C                 Use 1000 for output the array of Sa with period
C Rjb = Joyner-Boore distance (km)
C Fault_Type    = US for unspecified fault 
C               = SS for strike-slip fault
C               = NF for normal fault
C               = RF for reverse fault
C Vs30          = shear wave velocity averaged over top 30 m in m/s
C
C Output Variables
C Sa: Median spectral acceleration prediction
C sigma: logarithmic standard deviation of spectral acceleration
C          prediction
C---------------------------------------------------------------------
C-------------------------Define Constants----------------------------
C---------------------------------------------------------------------
      data period/-10, -1, 0, 0.01, 0.02, 0.03, 0.05, 0.075, 0.1, 0.15,
     +0.2, 0.25, 0.3, 0.4, 0.5, 0.75, 1, 1.5, 2, 3, 4, 5, 7.5, 10/
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C find the integer place holder that defines the period
      ip=0
      do j=1,L1
         if(INT(period(j)*1000) .eq. INT(1000*T)) ip=j
	enddo
C---------------------------------------------------------------------
C Computation of pga4nl
C if T==-10
      if(ip .eq. 1) then
          call BA_2008_nga10(M, -10, Rjb, FType, Vs30, Sa, sigma, 
     +                            0.0)
      else
          call BA_2008_nga10(M, -10, Rjb, FType, Vs30, pTemp, sigma, 
     +                            0.0)
          call BA_2008_nga_Sub(M, T, Rjb, FType, Vs30, Sa, sigma, 
     +                            pTemp)
      endif    
    
      end subroutine BA_2008_nga
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C---------------------------------------------------------------------
      subroutine BA_2008_nga_Sub(M, T, Rjb, FType, Vs30, Sa, sigma, 
     +                            pga4nl)
      implicit none
      integer             :: i, ip, j, k, L1
      real                :: M, T, Rjb, Vs30, Sa, sigma, U, S, N, R
      real                :: Fm, Fd, rr, lny, Flin, bnl, deltax, deltay
      real                :: c, d, Fnl, Fs, pga4nl
      character*10        :: FType
      parameter(L1 = 24)
      real, dimension(L1) :: period, e01, e02, e03, e04, e05, e06, e07
      real, dimension(L1) :: mh, c01, c02, c03, mref, rref, h, blin 
      real, dimension(L1) :: vref, b1, b2, v1, v2, a1
      real, dimension(L1) :: pga_low, a2, sig1, sig2u, sigtu, sig2m
      real, dimension(L1) :: sigtm

C---------------------------------------------------------------------
C-------------------------Define Constants----------------------------
C---------------------------------------------------------------------

      data period/-10, -1, 0, 0.01, 0.02, 0.03, 0.05, 0.075, 0.1, 0.15,
     +0.2, 0.25, 0.3, 0.4, 0.5, 0.75, 1, 1.5, 2, 3, 4, 5, 7.5, 10/

      data e01/-0.03279, 5.00121, -0.53804, -0.52883, -0.52192,
     + -0.45285, -0.28476, 0.00767, 0.20109, 0.46128, 0.5718, 0.51884, 
     +0.43825, 0.3922, 0.18957, -0.21338, -0.46896, -0.86271, -1.22652,
     +-1.82979, -2.24656, -1.28408, -1.43145, -2.15446/

      data e02/-0.03279, 5.04727, -0.5035, -0.49429, -0.48508, 
     +-0.41831, -0.25022, 0.04912, 0.23102, 0.48661, 0.59253, 0.53496, 
     +0.44516, 0.40602, 0.19878, -0.19496, -0.43443, -0.79593, -1.15514,
     +-1.7469, -2.15906, -1.2127, -1.31632, -2.16137/

      data e03/-0.03279, 4.63188, -0.75472, -0.74551, -0.73906, 
     +-0.66722, -0.48462, -0.20578, 0.03058, 0.30185, 0.4086, 0.3388, 
     +0.25356, 0.21398, 0.00967, -0.49176, -0.78465, -1.20902, 
     +-1.57697, -2.22584, -2.58228, -1.50904, -1.81022, -2.53323/

      data e04/-0.03279, 5.0821, -0.5097, -0.49966, -0.48895, -0.42229, 
     +-0.26092, 0.02706, 0.22193, 0.49328, 0.61472, 0.57747, 0.5199, 
     +0.4608, 0.26337, -0.10813, -0.3933, -0.88085, -1.27669, -1.91814,
     +-2.38168, -1.41093, -1.59217, -2.14635/

      data e05/0.29795, 0.18322, 0.28805, 0.28897, 0.25144, 0.17976, 
     +0.06369, 0.0117, 0.04697, 0.1799, 0.52729, 0.6088, 0.64472, 
     +0.7861, 0.76837, 0.75179, 0.6788, 0.70689, 0.77989, 0.77966, 
     +1.24961, 0.14271, 0.52407, 0.40387/

      data e06/-0.20341, -0.12736, -0.10164, -0.10019, -0.11006, 
     +-0.12858, -0.15752, -0.17051, -0.15948, -0.14539, -0.12964, 
     +-0.13843, -0.15694, -0.07843, -0.09054, -0.14053, -0.18257, 
     +-0.2595, -0.29657, -0.45384, -0.35874, -0.39006, -0.37578, 
     +-0.48492/

      data e07/0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.00102, 0.08607, 0.10601, 
     +0.02262, 0, 0.10302, 0.05393, 0.19082, 0.29888, 0.67466, 0.79508, 
     +0, 0, 0/

      data mh/7, 8.5, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 
     +6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 
     +8.5, 8.5, 8.5/

      data c01/-0.55, -0.8737, -0.6605, -0.6622, -0.666, -0.6901, 
     +-0.717, -0.7205, -0.7081, -0.6961, -0.583, -0.5726, -0.5543, 
     +-0.6443, -0.6914, -0.7408, -0.8183, -0.8303, -0.8285, -0.7844, 
     +-0.6854, -0.5096, -0.3724, -0.09824/

      data c02/0, 0.1006, 0.1197, 0.12, 0.1228, 0.1283, 0.1317, 0.1237, 
     +0.1117, 0.09884, 0.04273, 0.02977, 0.01955, 0.04394, 0.0608, 
     +0.07518, 0.1027, 0.09793, 0.09432, 0.07282, 0.03758, -0.02391, 
     +-0.06568, -0.138/

      data c03/-0.01151, -0.00334, -0.01151, -0.01151, -0.01151, 
     +-0.01151, -0.01151, -0.01151, -0.01151, -0.01113, -0.00952, 
     +-0.00837, -0.0075, -0.00626, -0.0054, -0.00409, -0.00334, 
     +-0.00255, -0.00217, -0.00191, -0.00191, -0.00191, -0.00191, 
     +-0.00191/

      data mref/4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 
     +4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5/
      data rref/5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
     +1, 1, 1, 1, 1, 1/

      data h/3, 2.54, 1.35, 1.35, 1.35, 1.35, 1.35, 1.55, 1.68, 1.86, 
     +1.98, 2.07, 2.14, 2.24, 2.32, 2.46, 2.54, 2.66, 2.73, 2.83, 2.89, 
     +2.93, 3, 3.04/

      data blin/0, -0.6, -0.36, -0.36, -0.34, -0.33, -0.29, -0.23, 
     +-0.25, -0.28, -0.31, -0.39, -0.44, -0.5, -0.6, -0.69, -0.7, 
     +-0.72, -0.73, -0.74, -0.75, -0.75, -0.692, -0.65/

      data vref/0, 760, 760, 760, 760, 760, 760, 760, 760, 760, 760, 
     +760, 760, 760, 760, 760, 760, 760, 760, 760, 760, 760, 760, 760/
      data b1/0, -0.5, -0.64, -0.64, -0.63, -0.62, -0.64, -0.64, -0.6, 
     +-0.53, -0.52, -0.52, -0.52, -0.51, -0.5, -0.47, -0.44, -0.4, 
     +-0.38, -0.34, -0.31, -0.291, -0.247, -0.215/

      data b2/0, -0.06, -0.14, -0.14, -0.12, -0.11, -0.11, -0.11, 
     +-0.13, -0.18, -0.19, -0.16, -0.14, -0.1, -0.06, 0, 0, 0, 0, 0, 
     +0, 0, 0, 0/

      data v1/0, 180, 180, 180, 180, 180, 180, 180, 180, 180, 180, 
     +180, 180, 180, 180, 180, 180, 180, 180, 180, 180, 180, 180, 180/

      data v2/0, 300, 300, 300, 300, 300, 300, 300, 300, 300, 300, 
     +300, 300, 300, 300, 300, 300, 300, 300, 300, 300, 300, 300, 300/

      data a1/0, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 
     +0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 
     +0.03, 0.03, 0.03/

      data pga_low/0, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 
     +0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 
     +0.06, 0.06, 0.06, 0.06, 0.06/

      data a2/0, 0.09, 0.09, 0.09, 0.09, 0.09, 0.09, 0.09, 0.09, 0.09, 
     +0.09, 0.09, 0.09, 0.09, 0.09, 0.09, 0.09, 0.09, 0.09, 0.09, 
     +0.09, 0.09, 0.09, 0.09/

      data sig1/0, 0.5, 0.502, 0.502, 0.502, 0.507, 0.516, 0.513, 0.52, 
     +0.518, 0.523, 0.527, 0.546, 0.541, 0.555, 0.571, 0.573, 0.566, 
     +0.58, 0.566, 0.583, 0.601, 0.626, 0.645/

      data sig2u/0, 0.286, 0.265, 0.267, 0.267, 0.276, 0.286, 0.322, 
     +0.313, 0.288, 0.283, 0.267, 0.272, 0.267, 0.265, 0.311, 0.318, 
     +0.382, 0.398, 0.41, 0.394, 0.414, 0.465, 0.355/

      data sigtu/0, 0.576, 0.566, 0.569, 0.569, 0.578, 0.589, 0.606, 
     +0.608, 0.592, 0.596, 0.592, 0.608, 0.603, 0.615, 0.649, 0.654, 
     +0.684, 0.702, 0.7, 0.702, 0.73, 0.781, 0.735/

      data sig2m/0, 0.256, 0.26, 0.262, 0.262, 0.274, 0.286, 0.32, 
     +0.318, 0.29, 0.288, 0.267, 0.269, 0.267, 0.265, 0.299, 0.302, 
     +0.373, 0.389, 0.401, 0.385, 0.437, 0.477, 0.477/

      data sigtm/0, 0.56, 0.564, 0.566, 0.566, 0.576, 0.589, 0.606, 
     +0.608, 0.594, 0.596, 0.592, 0.608, 0.603, 0.615, 0.645, 0.647, 
     +0.679, 0.7, 0.695, 0.698, 0.744, 0.787, 0.801/
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C find the integer place holder that defines the period
      ip=0
      do j=1,L1
         if(INT(period(j)*1000) .eq. INT(1000*T)) ip=j
	enddo
C---------------------------------------------------------------------
C---------------------------------------------------------------------
      if(FType .eq. 'SS') then
            U = 0.0
            S = 1.0
            N = 0.0
            R = 0.0
      elseif(FType .eq. 'NF') then
            U = 0.0
            S = 0.0
            N = 1.0
            R = 0.0
      elseif(FType .eq. 'RF') then
            U = 0.0
            S = 0.0
            N = 0.0
            R = 1.0
      else
            U = 1.0
            S = 0.0
            N = 0.0
            R = 0.0
      endif
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C Magnitude Scaling

      if(M .le. mh (ip)) then
          Fm = e01(ip)*U+e02(ip)*S+e03(ip)*N+e04(ip)*R+
     +         e05(ip)*(M-mh(ip))+e06(ip)*(M-mh(ip))**2
      else
          Fm = e01(ip)*U+e02(ip)*S+e03(ip)*N+e04(ip)*R+
     +         e07(ip)*(M-mh(ip))
      endif

C Distance Scaling

      rr= SQRT(Rjb**2+h(ip)**2)
      Fd = (c01(ip)+c02(ip)*(M-mref(ip)))*LOG(rr/rref(ip))+
     +      c03(ip)*(rr-rref(ip))

C if T==-10
      if(ip .eq. 1) then
          lny = Fm + Fd
          Sa = EXP(lny)
          sigma = -1.0
          return
      endif

C Site Amplification
C Linear term
      Flin = blin(ip) * LOG(Vs30 / vref(ip))

C Nonlinear term
C Computation of nonlinear factor
      if(Vs30 .le. v1(ip)) then
          bnl = b1(ip)
      elseif(Vs30 .le. v2(ip)) then
          bnl = b2(ip)+
     +          (b1(ip)-b2(ip))*LOG(Vs30/v2(ip))/LOG(v1(ip)/v2(ip))
      elseif(Vs30 .le. vref(ip)) then
          bnl = b2(ip) * LOG(Vs30/vref(ip))/LOG(v2(ip)/vref(ip))
      else
          bnl = 0.0
      endif

      deltax = LOG(a2(ip)/a1(ip))
      deltay = bnl*LOG(a2(ip)/pga_low(ip))
      c = (3.0*deltay-bnl*deltax)/(deltax**2)
      d = -1.0*(2.0*deltay-bnl*deltax)/(deltax**3)

      if(pga4nl .le. a1(ip)) then
          Fnl = bnl*LOG(pga_low(ip)/0.1)
      elseif(pga4nl .le. a2(ip)) then
          Fnl = bnl*LOG(pga_low(ip)/0.1)+c*(LOG(pga4nl/a1(ip)))**2 + 
     +          d*(LOG(pga4nl/a1(ip)))**3
      else
          Fnl = bnl*LOG(pga4nl/0.1)
      endif

      Fs = Flin + Fnl

C Compute median and sigma
      lny = Fm + Fd + Fs
      Sa = EXP(lny)
      if(U .eq. 1.0) then
            sigma = sigtu(ip)
      else
            sigma = sigtm(ip)
      endif

      end subroutine BA_2008_nga_Sub
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C---------------------------------------------------------------------
      subroutine BA_2008_nga10(M, T, Rjb, FType, Vs30, Sa, sigma, 
     +                            pga4nl)
      implicit none
      integer             :: i, ip, j, k, L1
      real                :: M, T, Rjb, Vs30, Sa, sigma, U, S, N, R
      real                :: Fm, Fd, rr, lny, Flin, bnl, deltax, deltay
      real                :: c, d, Fnl, Fs, pga4nl
      character*10        :: FType
      parameter(L1 = 24)
      real, dimension(L1) :: period, e01, e02, e03, e04, e05, e06, e07
      real, dimension(L1) :: mh, c01, c02, c03, mref, rref, h, blin 
      real, dimension(L1) :: vref, b1, b2, v1, v2, a1
C---------------------------------------------------------------------
C-------------------------Define Constants----------------------------
C---------------------------------------------------------------------
      data period/-10, -1, 0, 0.01, 0.02, 0.03, 0.05, 0.075, 0.1, 0.15,
     +0.2, 0.25, 0.3, 0.4, 0.5, 0.75, 1, 1.5, 2, 3, 4, 5, 7.5, 10/

      data e01/-0.03279, 5.00121, -0.53804, -0.52883, -0.52192,
     + -0.45285, -0.28476, 0.00767, 0.20109, 0.46128, 0.5718, 0.51884, 
     +0.43825, 0.3922, 0.18957, -0.21338, -0.46896, -0.86271, -1.22652,
     +-1.82979, -2.24656, -1.28408, -1.43145, -2.15446/

      data e02/-0.03279, 5.04727, -0.5035, -0.49429, -0.48508, 
     +-0.41831, -0.25022, 0.04912, 0.23102, 0.48661, 0.59253, 0.53496, 
     +0.44516, 0.40602, 0.19878, -0.19496, -0.43443, -0.79593, -1.15514,
     +-1.7469, -2.15906, -1.2127, -1.31632, -2.16137/

      data e03/-0.03279, 4.63188, -0.75472, -0.74551, -0.73906, 
     +-0.66722, -0.48462, -0.20578, 0.03058, 0.30185, 0.4086, 0.3388, 
     +0.25356, 0.21398, 0.00967, -0.49176, -0.78465, -1.20902, 
     +-1.57697, -2.22584, -2.58228, -1.50904, -1.81022, -2.53323/

      data e04/-0.03279, 5.0821, -0.5097, -0.49966, -0.48895, -0.42229, 
     +-0.26092, 0.02706, 0.22193, 0.49328, 0.61472, 0.57747, 0.5199, 
     +0.4608, 0.26337, -0.10813, -0.3933, -0.88085, -1.27669, -1.91814,
     +-2.38168, -1.41093, -1.59217, -2.14635/

      data e05/0.29795, 0.18322, 0.28805, 0.28897, 0.25144, 0.17976, 
     +0.06369, 0.0117, 0.04697, 0.1799, 0.52729, 0.6088, 0.64472, 
     +0.7861, 0.76837, 0.75179, 0.6788, 0.70689, 0.77989, 0.77966, 
     +1.24961, 0.14271, 0.52407, 0.40387/

      data e06/-0.20341, -0.12736, -0.10164, -0.10019, -0.11006, 
     +-0.12858, -0.15752, -0.17051, -0.15948, -0.14539, -0.12964, 
     +-0.13843, -0.15694, -0.07843, -0.09054, -0.14053, -0.18257, 
     +-0.2595, -0.29657, -0.45384, -0.35874, -0.39006, -0.37578, 
     +-0.48492/

      data e07/0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.00102, 0.08607, 0.10601, 
     +0.02262, 0, 0.10302, 0.05393, 0.19082, 0.29888, 0.67466, 0.79508, 
     +0, 0, 0/

      data mh/7, 8.5, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 
     +6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 
     +8.5, 8.5, 8.5/

      data c01/-0.55, -0.8737, -0.6605, -0.6622, -0.666, -0.6901, 
     +-0.717, -0.7205, -0.7081, -0.6961, -0.583, -0.5726, -0.5543, 
     +-0.6443, -0.6914, -0.7408, -0.8183, -0.8303, -0.8285, -0.7844, 
     +-0.6854, -0.5096, -0.3724, -0.09824/

      data c02/0, 0.1006, 0.1197, 0.12, 0.1228, 0.1283, 0.1317, 0.1237, 
     +0.1117, 0.09884, 0.04273, 0.02977, 0.01955, 0.04394, 0.0608, 
     +0.07518, 0.1027, 0.09793, 0.09432, 0.07282, 0.03758, -0.02391, 
     +-0.06568, -0.138/

      data c03/-0.01151, -0.00334, -0.01151, -0.01151, -0.01151, 
     +-0.01151, -0.01151, -0.01151, -0.01151, -0.01113, -0.00952, 
     +-0.00837, -0.0075, -0.00626, -0.0054, -0.00409, -0.00334, 
     +-0.00255, -0.00217, -0.00191, -0.00191, -0.00191, -0.00191, 
     +-0.00191/

      data mref/4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 
     +4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5/
      data rref/5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
     +1, 1, 1, 1, 1, 1/

      data h/3, 2.54, 1.35, 1.35, 1.35, 1.35, 1.35, 1.55, 1.68, 1.86, 
     +1.98, 2.07, 2.14, 2.24, 2.32, 2.46, 2.54, 2.66, 2.73, 2.83, 2.89, 
     +2.93, 3, 3.04/
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C find the integer place holder that defines the period
      ip=1
C---------------------------------------------------------------------
C---------------------------------------------------------------------
      if(FType .eq. 'SS') then
            U = 0.0
            S = 1.0
            N = 0.0
            R = 0.0
      elseif(FType .eq. 'NF') then
            U = 0.0
            S = 0.0
            N = 1.0
            R = 0.0
      elseif(FType .eq. 'RF') then
            U = 0.0
            S = 0.0
            N = 0.0
            R = 1.0
      else
            U = 1.0
            S = 0.0
            N = 0.0
            R = 0.0
      endif
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C Magnitude Scaling
      if(M .le. mh(ip)) then
          Fm = e01(ip)*U+e02(ip)*S+e03(ip)*N+e04(ip)*R+
     +         e05(ip)*(M-mh(ip))+e06(ip)*(M-mh(ip))**2
      else
          Fm = e01(ip)*U+e02(ip)*S+e03(ip)*N+e04(ip)*R+
     +         e07(ip)*(M-mh(ip))
      endif

C Distance Scaling

      rr= SQRT(Rjb**2+h(ip)**2)
      Fd = (c01(ip)+c02(ip)*(M-mref(ip)))*LOG(rr/rref(ip))+
     +      c03(ip)*(rr-rref(ip))

C if T==-10
          lny = Fm + Fd
          Sa = EXP(lny)
          sigma = -1.0
      end subroutine BA_2008_nga10