defmodule Measurements.Scale do



	defstruct ten_power: 0
		  

  @typedoc "Scale Type"
  @type t :: %__MODULE__{
          ten_power: integer
        }


   def new(ten_power) do
   	%__MODULE__{ten_power: ten_power }
   end


   def prod(%__MODULE__{} = s1, %__MODULE__{} = s2) do
   	%__MODULE__{
   		ten_power: s1.ten_power + s2.ten_power
   		}

   end


   def ratio(%__MODULE__{} = s1, %__MODULE__{} = s2) do
   	%__MODULE__{
   		ten_power: s1.ten_power - s2.ten_power
   	}
   end


   def convert(%__MODULE__{ten_power: tp}) do
   	fn v -> v * 10 ** tp end
   end


end