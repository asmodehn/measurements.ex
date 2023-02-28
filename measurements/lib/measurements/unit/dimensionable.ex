   defmodule Dimensionable do
   	
   		@callback dimension(atom()) :: Measurements.Dimension.t

   end