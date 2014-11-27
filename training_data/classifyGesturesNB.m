
function classifyGesturesNB
    clear all; clear;
    
    %Using the larger test data for training increases performance
    O = load('O.txt');
    X = load('X.txt');
    Z = load('Z.txt');
    num_features = size(O ,2);
    %plotGestureData(O, 1);
    %plotGestureData(X, 2);
    %plotGestureData(Z, 3);
    
    training_instance_matrix = [O; X; Z;];
    training_label_vector = [zeros(size(O, 1), 1); ones(size(X, 1), 1); 2 * ones(size(Z, 1), 1);];
    
    %Smoothing with box filter seems to work better than gaussian filter
    training_instance_matrix = smoothts(training_instance_matrix, 'b', 25);
    %plotGestureData(training_instance_matrix(1:size(O, 1),:), 4);
    
    %m = round(size(training_instance_matrix, 1) * 7 / 10); 
	
	% 25 60  
		
	min_endpoint = 60
	max_endpoint = 60
	
	trainAccuracy = zeros(1, max_endpoint - min_endpoint + 1);
	testAccuracy = zeros(1, max_endpoint - min_endpoint + 1);
    
	for m = min_endpoint:max_endpoint
		m
	    numCorrect = 0;
	    numCorrectTrain = 0;
	    %Resample
	    iterations = 1000;
	    for i = 1:iterations
			i
			% For Gaussian distribution, each class must have at least two observations. Otherwise, NaiveBayes.fit crashes.
			
			% This while loop may be slow for small m
			while 1
				[X_train, X_test, y_train, y_test] = getRandomSplitExamples(training_instance_matrix, training_label_vector, m);
			
				if (sum(y_train == 0) >= 2) && (sum(y_train == 1) >= 2) && (sum(y_train == 2) >= 2)
					break
				end
			end
        
	        model = fitNaiveBayes(X_train, y_train);
	        %model = svmtrain(y_train, X_train, '-s 0 -t 2');
        
	        %Training error - it's always 100%
	        train_predictions = model.predict(X_train);
	        numCorrectTrain = numCorrectTrain +  findNumCorrect(train_predictions, y_train);
	        %Testing error
	        test_predictions = model.predict(X_test);
	        numCorrect = numCorrect +  findNumCorrect(test_predictions, y_test);
	    end
	    trainAccuracy(1, m - min_endpoint + 1) = numCorrectTrain / (iterations * m)
	    testAccuracy(1, m - min_endpoint + 1) = numCorrect / (iterations * (size(training_instance_matrix, 1) - m))   
	end
	
	%%% Plot "Bias and Variance" %%%
	
	fig = figure;
	hold on;

	X_data = min_endpoint:max_endpoint;
	plot(X_data, 1 - trainAccuracy, 'b');
	plot(X_data, 1 - testAccuracy, 'r');

	title('Naive Bayes Bias and Variance');
	xlabel('Number of Training Examples');
	ylabel('Classification Error');
	legend('Training', 'Test');
	% for some reason I can't view the plot, so I save it
	print -dpdf fig; % saved in fig.pdf
	saveas(fig, 'plot.png')
	
end

function [X,Y,Z] = splitData(G)
    X = G(:, 1:100);
    Y = G(:, 101:200);
    Z = G(:, 201:300); 
end

function plotGestureData(G, figure_count)
    figure_num = (figure_count - 1) * 2 + 1;
    figure(figure_num);
    [X,Y,Z] = splitData(G);
    for i = 1:size(X,1)
        plot3(X(i,:),Y(i,:),Z(i,:));
        hold on;
    end
    title('All training examples');
    hold off;
    
    figure(figure_num + 1);
    plot3(X(1,:),Y(1,:),Z(1,:));
    title('One(first) training example');
    
end

function numCorrect = findNumCorrect(pred, actual)
    numCorrect = sum(pred == actual);
end

function [X_train, X_test, y_train, y_test] = getRandomSplitExamples(X, y, m)
    indices = datasample(1:size(X,1), m, 'Replace',false);
    X_train = zeros(m, size(X,2));
    X_test = zeros(size(X,1) - m, size(X,2));
    y_train = zeros(m, 1);
    y_test = zeros(size(y ,1) - m, 1);
    
    x_train_count = 1;
    x_test_count = 1;
    y_train_count = 1;
    y_test_count = 1;
    for i = 1:size(X,1)
        if any(i==indices)
            X_train(x_train_count, :) = X(i,:);
            y_train(y_train_count, :) = y(i,:);
            x_train_count = x_train_count + 1;
            y_train_count = y_train_count + 1;
        else
            X_test(x_test_count, :) = X(i, :);
            y_test(y_test_count, :) = y(i, :);
            x_test_count = x_test_count + 1;
            y_test_count = y_test_count + 1;
        end
        
    end
end