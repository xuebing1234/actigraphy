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


function feature_space=get_features(data, flag)
    high=60;
    low=50;
    if flag==1
        period=15;
        count_before=7;
    else
        count_before=4;
        period=9;
    end
    feature_space=zeros(size(data,1),6);
    for i= 1: size(data,1)

        if i<round(period/2)
            starting_index=1;
            ending_index=period;
        else
            if i>size(data,1)-count_before
                starting_index=size(data,1)-period+1;
                ending_index=size(data,1);
            else
                starting_index=i-count_before;
                ending_index=i+count_before;
            end
        end
        avg=mean(data(starting_index:ending_index));
        if avg==0
            avg=1;
        end
        % para 1: max
        maximum=max(data(starting_index:ending_index))/avg;

        % para 2: std
        st_dev=std(data(starting_index:ending_index));
        % para 3, 4, and 5: counts in each category
        count_zero=sum(data(starting_index:ending_index)==0);
        count_low=sum(data(starting_index:ending_index)<=low)-count_zero;
        count_high=sum(data(starting_index:ending_index)>high);
        ratio_zero=count_zero/(ending_index-starting_index+1);
        ratio_low=count_low/(ending_index-starting_index+1);
        ratio_high=count_high/(ending_index-starting_index+1);
        % para 6: crossing rate
        count=0;
        for j=starting_index:ending_index-1
            if (data(j)-avg)*(data(j+1)-avg)<0
                count=count+1;
            end
        end
        cross_rate=count/(period-1);

        feature_space(i,:)=[maximum, st_dev,ratio_zero, ratio_low,ratio_high, cross_rate];

    end
end