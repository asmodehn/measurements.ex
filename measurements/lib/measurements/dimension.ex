defmodule Measurements.Dimension do


defstruct time: 0 , 
		  length: 0,
		  mass: 0, 
		  current: 0,
		   temperature: 0,
		  substance: 0,
		   lintensity: 0


  @typedoc "Dimension Type"
  @type t :: %__MODULE__{
          time: integer,
          length: integer,
          mass: integer,
          current: integer,
          temperature: integer,
          substance: integer,
          lintensity: integer
        }


   def new() do
   	%__MODULE__{}
   end

   def with_time(%__MODULE__{} = d, n) do
   	%{d | time: d.time + n}
   end

   def with_length(%__MODULE__{} = d, n) do
   	%{d | length: d.length + n}
   end

   def with_mass(%__MODULE__{} = d, n) do
   	%{d | mass: d.mass + n}
   end

   def with_current(%__MODULE__{} = d, n) do
   	%{d | current: d.current + n}
   end

   def with_temperature(%__MODULE__{} = d, n) do
   	%{d | temperature: d.temperature + n}
   end

   def with_substance(%__MODULE__{} = d, n) do
   	%{d | substance: d.substance + n}
   end

   def with_lintensity(%__MODULE__{} = d, n) do
   	%{d | lintensity: d.lintensity + n}
   end



   def prod(%__MODULE__{} = d1, %__MODULE__{} = d2) do
   	%__MODULE__{
   		time: d1.time + d2.time,
   		length: d1.length + d2.length,
   		mass: d1.mass + d2.mass,
   		current: d1.current + d2.current,
   		temperature: d1.temperature + d2.temperature,
   		substance: d1.substance + d2.substance,
   		lintensity: d1.lintensity + d2.lintensity
   	}

   end


   def ratio(%__MODULE__{} = d1, %__MODULE__{} = d2) do
   	%__MODULE__{
   		time: d1.time - d2.time,
   		length: d1.length - d2.length,
   		mass: d1.mass - d2.mass,
   		current: d1.current - d2.current,
   		temperature: d1.temperature - d2.temperature,
   		substance: d1.substance - d2.substance,
   		lintensity: d1.lintensity - d2.lintensity
   	}
   end

end