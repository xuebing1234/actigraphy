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