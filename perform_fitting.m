
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

