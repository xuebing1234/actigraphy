function ypred=sleep_predict(testdata, para, interval, flag) 
%      
%     testdata: n x 1 vector of training data
%     para: d (d==7) x 1 vector of training model from perform_fitting
%     function
%     interval: parameter for defining sleep onset. default: 10    
%     flag: 1 for CP children, 0 otherwise
    feature_test=get_features(testdata,flag);
    feature_test= [ones(size(testdata,1),1), feature_test];
    ypred = sign (feature_test * para.' ); 
    ypred= (ypred+1) /2;
    sleep_time=find_sleep(ypred,interval)
    tst=sum(ypred)
    total_time=size(ypred,1)
    eff=tst/total_time
    latency=sleep_time
    WASO=total_time-sleep_time+1-sum(ypred(sleep_time:end))
    
end

function sleep_time=find_sleep(ypred,interval)
    for i=1:size(ypred,1)
        sleep_time=i;
        if (sleep_time+interval) > size(ypred,1)
            sleep_time=size(ypred,1);
            
            break
        end
        if sum(ypred(i:i+interval-1))>=(interval-1)
            break
        end
    end
        
end

