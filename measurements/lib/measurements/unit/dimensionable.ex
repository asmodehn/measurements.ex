   defmodule Measurements.Unit.Dimensionable do
   	
   		@callback dimension(atom()) :: Measurements.Dimension.t

   end