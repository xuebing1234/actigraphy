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