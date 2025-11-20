function mdot = mDyer(mSPI, mHEM, phase)
    K = 1;
    
    mdot = (1 - 1 / (1 + K)) * mSPI + (1 / (1 + K)) * mHEM;

end