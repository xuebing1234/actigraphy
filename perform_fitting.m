
function para=perform_fitting(data,labels, flag)
%      
%     data: n x 1 vector of training data
%     labels: n x 1 vector (0 or 1) of wake / sleep
%     flag: 1 for CP children, 0 otherwise
    switch nargin
        case 2
            flag = 0; 
        case 0
            msg= 'inputs needed: training data vector, data labels vector';
            error(msg);
        case 1 
            msg='insufficient # of arguments';
            error(msg);
    end
    feature_space = get_features (data, flag);
    weights=calculate_weight(data, labels);
    
    num_folds=3;
    num_shuffles=2;
    test_kfold=zeros(num_shuffles*num_folds,11);
    index=1;
    for j = 1:num_shuffles
        
        indices  = crossvalind('Kfold',data,num_folds);
        for i = 1:num_folds
            
            test = (indices == i); 
            train = ~test;
            mdl = fitglm(feature_space(train,:),labels(train),'linear','Distribution','binomial','link','logit','Weights',weights(train));
            ypred = predict(mdl,feature_space(test,:));
            
            stats=find_detail(labels(test),ypred);
            [X,Y,T,AUC,OPTROCPT] = perfcurve(labels(test),ypred,1);
                     
            test_kfold(index,:)=[AUC, stats, mdl.Coefficients.Estimate.']
            index=index+1;
        end
    end
    %returns AUC, Accu, Sens, Spec, and model parameters
    test_kfold=mean(test_kfold, 1);
    disp('average AUC, accuracy, sensitivity and specificity are: ');
    test_kfold(1:4)
    para=test_kfold(5:11);
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
function result=find_detail(data,prediction)
    count_sensitivity=0;
    total_sensitivity=0;
    count_specificity=0;
    total_specificity=0;
    ratio_pos=nnz(data)/size(data,1);
    result=zeros(1,3);
   for i=1:size(data,1)
       if data(i)==1
            total_sensitivity=total_sensitivity+1;
            %sensitivity
            if prediction(i)>0.5
                count_sensitivity=count_sensitivity+1;
            end

        else                        
            %specificity
            total_specificity=total_specificity+1;
            if prediction(i)<=0.5
                count_specificity=count_specificity+1;
            end               
        end
    end
    sensitivity=count_sensitivity/total_sensitivity;
    specificity=count_specificity/total_specificity;
    result=[sensitivity*ratio_pos+specificity*(1-ratio_pos), sensitivity,specificity];
end
function weights=calculate_weight(data, labels)
% returns a nx1 vector of weights for each epoch
    weights=zeros(size(data));
    ratio=sum(labels)/size(labels,1);
 % alternatively, when using pWLR model, ratio can also be calculated with
 % ratio = sum( # of wake epochs for all participants ) / # of epochs ,
 % because some participants have very few sleep epochs during PSG
 % night, especially for CP children
 
    for i=1:size(data,1)
        if labels(i)==1
            weights(i)=1- ratio;
            
        else
            weights(i)=ratio;
            
        end
    end

        
end
