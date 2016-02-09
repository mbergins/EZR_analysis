function output_mat = convert_struct_to_matrix(input_struct,varargin)
% convert_struct_to_matrix - Take an input_struct and convert it to a
% matrix.
%
% Parameters:
%   input_struct - struct consisting of one dimensional vectors
%
% Output:
%   output_mat - matrix containing the data from the input struct, data is
%     ordered by the fieldnames command with NaN filling in slots where one
%     field has less data than others

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;

i_p.addRequired('input_struct',@(x)strcmp(class(x),{'struct'}));

i_p.addParameter('debug',0,@(x)x==1 || x==0);

i_p.parse(input_struct,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fields = fieldnames(input_struct);

max_size = 0;
for i = 1:length(fields)
    if (length(input_struct.(fields{i})) > max_size)
        max_size = length(input_struct.(fields{i}));
    end
end

output_mat = NaN*ones(max_size,length(fields));
for i = 1:length(fields)
    this_data = input_struct.(fields{i});
    output_mat(1:length(this_data),i) = this_data;
end

end