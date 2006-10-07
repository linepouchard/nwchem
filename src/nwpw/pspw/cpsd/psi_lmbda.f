*
* $Id: psi_lmbda.f,v 1.7 2006-10-07 00:10:06 bylaska Exp $
*

*     ********************************************
*     *                                          *
*     *                psi_lmbda                 *
*     *                                          *
*     ********************************************

      subroutine psi_lmbda(ispin,ne,nemax,npack1,
     >                     psi1,psi2,
     >                     dte,
     >                     lmbda,tmp,ierr)

      implicit none
      integer ispin,ne(2),nemax,npack1
      complex*16 psi1(npack1,nemax)
      complex*16 psi2(npack1,nemax)
      real*8     dte
      real*8     lmbda(*)
      real*8     tmp(*)
      integer	 ierr

      integer MASTER
      parameter (MASTER=0)

*     **** local variables ****
      integer taskid,i
      integer n1(2)
      integer ms,it
      integer nn
      integer s11,s12,s21,s22,st1,st2,sa1,sa0
      real*8  adiff

*     ::::  iteration limit and tolerence for non-liner equations  ::::
      integer itrlmd
      real*8  convg
      parameter (itrlmd=20, convg=1.0d-15)

*     **** external functions ****
      real*8   DMatrix_m_dmax
      external DMatrix_m_dmax

      call nwpw_timing_start(3)

      n1(1) = 1
      n1(2) = ne(1)+1
      call Dneall_m_size(1,nn)
      
      s11  = 0*nn + 1
      s12  = 1*nn + 1
      s21  = 2*nn + 1
      s22  = 3*nn + 1
      sa0  = 4*nn + 1
      sa1  = 5*nn + 1
      st1  = 6*nn + 1
      st2  = 7*nn + 1

      call dcopy(8*nn,0.0d0,0,tmp,1)

      
*::::::::::::::::::::::  Lagrangian multipliers  ::::::::::::::::::::::
      DO 640 ms=1,ispin
        IF(ne(ms).le.0) GO TO 640

        call DMatrix_ffm_sym_Multiply(ms,psi2,psi2,npack1,tmp(s22))
        call DMatrix_ffm_sym_Multiply(ms,psi2,psi1,npack1,tmp(s21))
        call DMatrix_ffm_sym_Multiply(ms,psi1,psi1,npack1,tmp(s11))

*       ***** scale the overlap matrices ****
        call DMatrix_m_scale_s22(ms,dte,tmp(s22))
        call DMatrix_m_scale_s21(ms,dte,tmp(s21))
        call dcopy(nn,tmp(s21),1,tmp(s12),1)
        call DMatrix_m_scale_s11(ms,dte,tmp(s11))

        call dcopy(nn,tmp(s22),1,tmp(sa0),1)

        do it=1,itrlmd
          call dcopy(nn,tmp(s22),1,tmp(sa1),1)

          call DMatrix_mmm_Multiply(ms,
     >                              tmp(s21),tmp(sa0),1.0d0,
     >                              tmp(sa1),1.0d0)
          call DMatrix_mmm_Multiply(ms,
     >                              tmp(sa0),tmp(s12),1.0d0,
     >                              tmp(sa1),1.0d0)
          call DMatrix_mmm_Multiply(ms,
     >                              tmp(s11),tmp(sa0),1.0d0,
     >                              tmp(st1),0.0d0)
          call DMatrix_mmm_Multiply(ms,
     >                              tmp(sa0),tmp(st1),1.0d0,
     >                              tmp(sa1),1.0d0)
          call dcopy(nn,tmp(sa1),1,tmp(st1),1)
          call daxpy(nn,(-1.0d0),tmp(sa0),1,tmp(st1),1)

          adiff = DMatrix_m_dmax(ms,tmp(st1))
          if(adiff.lt.convg) GO TO 630
          call dcopy(nn,tmp(sa1),1,tmp(sa0),1)
        end do

        ierr=10 
        call Parallel_taskid(taskid)
        if (taskid.eq.MASTER) then
          WRITE(6,*) 
     >     'Warning: Lagrange Multiplier tolerance too high:',adiff
          WRITE(6,*) '        +Try using a smaller time step'
          WRITE(6,*) '        +Gram-Schmidt being performed, spin:',ms
        end if
        call Grsm_g_MakeOrtho(npack1,ne(ms),psi2(1,n1(ms)))

C       return
  630   continue
        call Dmatrix_mm_Expand(ms,tmp(sa1),lmbda)
  640 continue

*:::::::::::::::::  correction due to the constraint  :::::::::::::::::
      call DMatrix_fmf_Multiply(0,
     >                          psi1,npack1,
     >                          lmbda, dte,
     >                          psi2,1.0d0) 

      call nwpw_timing_end(3)

      return
      end

