clear;


load('CDOM-DOC.mat');

Data = table2struct(Data);



save('CDOM-DOC-R.mat', 'Abs', 'Data', 'Wave');
