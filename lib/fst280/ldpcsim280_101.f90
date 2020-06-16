program ldpcsim280_101

! End-to-end test of the (280,101)/crc24 encoder and decoders.

   use packjt77

   parameter(N=280, K=101, M=N-K)
   character*8 arg
   character*37 msg0,msg
   character*77 c77
   character*24 c24
   integer*1 msgbits(101)
   integer*1 apmask(280)
   integer*1 cw(280)
   integer*1 codeword(N),message101(101)
   integer ncrc24
   real rxdata(N),llr(N)
   real llrd(280)
   logical first,unpk77_success
   data first/.true./

   nargs=iargc()
   if(nargs.ne.6 .and. nargs.ne.7) then
      print*,'Usage : ldpcsim        niter norder maxosd   #trials    s    K      [msg]'
      print*,'e.g.    ldpcsim280_101   20     3     2       1000    0.85  91 "K9AN K1JT FN20"'
      print*,'s     : if negative, then value is ignored and sigma is calculated from SNR.'
      print*,'niter : is the number of BP iterations.'
      print*,'norder: -1 is BP only, norder>=0 is OSD order'
      print*,'K     :is the number of message+CRC bits and must be in the range [77,101]'
      print*,'WSPR-format message is optional'
      return
   endif
   call getarg(1,arg)
   read(arg,*) max_iterations
   call getarg(2,arg)
   read(arg,*) norder
   call getarg(3,arg)
   read(arg,*) maxosd 
   call getarg(4,arg)
   read(arg,*) ntrials
   call getarg(5,arg)
   read(arg,*) s
   call getarg(6,arg)
   read(arg,*) Keff
   msg0='K9AN K1JT FN20                       '
   if(nargs.eq.7) call getarg(7,msg0)
   call pack77(msg0,i3,n3,c77)
   call unpack77(c77,0,msg,unpk77_success)
   if(unpk77_success) then
      write(*,1100) msg(1:37)
1100  format('Decoded message: ',a37)
   else
      print*,'Error unpacking message'
   endif
   
   rate=real(91)/real(N)

   write(*,*) "code rate: ",rate
   write(*,*) "niter    : ",max_iterations
   write(*,*) "norder   : ",norder
   write(*,*) "s        : ",s
   write(*,*) "K        : ",Keff

   msgbits=0
   read(c77,'(77i1)') msgbits(1:77)
   write(*,*) 'message'
   write(*,'(77i1)') msgbits(1:77)

   call get_crc24(msgbits,101,ncrc24)
   write(c24,'(b24.24)') ncrc24
   read(c24,'(24i1)') msgbits(78:101)
   write(*,*) 'message with crc24'
   write(*,'(101i1)') msgbits(1:101)
   call encode280_101(msgbits,codeword)
   call init_random_seed()
   call sgran()

   write(*,*) 'codeword'
   write(*,'(77i1,1x,24i1,1x,73i1)') codeword

   write(*,*) "Eb/N0    Es/N0   ngood  nundetected   sigma   symbol error rate"
   do idb = 8,-3,-1
      db=idb/2.0-1.0
      sigma=1/sqrt( 2*rate*(10**(db/10.0)) )  ! to make db represent Eb/No
!  sigma=1/sqrt( 2*(10**(db/10.0)) )        ! db represents Es/No
      ngood=0
      nue=0
      nberr=0
      do itrial=1, ntrials
! Create a realization of a noisy received word
         do i=1,N
            rxdata(i) = 2.0*codeword(i)-1.0 + sigma*gran()
         enddo
         nerr=0
         do i=1,N
            if( rxdata(i)*(2*codeword(i)-1.0) .lt. 0 ) nerr=nerr+1
         enddo
         nberr=nberr+nerr

         rxav=sum(rxdata)/N
         rx2av=sum(rxdata*rxdata)/N
         rxsig=sqrt(rx2av-rxav*rxav)
         rxdata=rxdata/rxsig
         if( s .lt. 0 ) then
            ss=sigma
         else
            ss=s
         endif

         llr=2.0*rxdata/(ss*ss)
         apmask=0
! max_iterations is max number of belief propagation iterations
         call bpdecode280_101(llr,apmask,max_iterations,message101,cw,nharderror,niterations,nchecks)
         dmin=0.0
         if( (nharderror .lt. 0) .and. (norder .ge. 0) ) then
!            call osd280_101(llr, Keff, apmask, norder, message101, cw, nharderror, dmin)
            call decode280_101(llr, Keff, maxosd, norder, apmask, message101, cw, ntype, nharderror, dmin)
         endif

         if(nharderror.ge.0) then
            n2err=0
            do i=1,N
               if( cw(i)*(2*codeword(i)-1.0) .lt. 0 ) n2err=n2err+1
            enddo
            if(n2err.eq.0) then
               ngood=ngood+1
            else
               nue=nue+1
            endif
         endif
      enddo
!      snr2500=db+10*log10(200.0/116.0/2500.0)
      esn0=db+10*log10(rate)
      pberr=real(nberr)/(real(ntrials*N))
      write(*,"(f4.1,4x,f5.1,1x,i8,1x,i8,8x,f5.2,8x,e10.3)") db,esn0,ngood,nue,ss,pberr

   enddo

end program ldpcsim280_101
