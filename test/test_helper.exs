ExUnit.start()

## Reminder: Stubs do not work when setup from here, as per https://stackoverflow.com/a/69465264

# System configuration for an optional mock, when setting native time_unit is required.
Hammox.defmock(Measurements.System.ExtraMock, for: Measurements.System.ExtraBehaviour)

Application.put_env(:measurements, :system_extra_module, Measurements.System.ExtraMock)

# Note this is only for tests.
# No configuration change on the user side is expected to set the System.Extra module.

# System configuration for an optional mock, when setting local time is required.
Hammox.defmock(Measurements.System.OriginalMock, for: Measurements.System.OriginalBehaviour)

Application.put_env(:measurements, :system_module, Measurements.System.OriginalMock)

# Note this is only for tests.
# No configuration change on the user side is expected to set the System module.

# Process configuration for an optional mock, when calling sleep without stopping is required.
Hammox.defmock(Measurements.Process.OriginalMock, for: Measurements.Process.OriginalBehaviour)

Application.put_env(:measurements, :process_module, Measurements.Process.OriginalMock)

# Note this is only for tests.
# No configuration change on the user side is expected to set the Process module.

# Node configuration for an optional mock, when calling self() with a mock is required.
Hammox.defmock(Measurements.Node.OriginalMock, for: Measurements.Node.OriginalBehaviour)

Application.put_env(:measurements, :node_module, Measurements.Node.OriginalMock)

# Note this is only for tests.
# No configuration change on the user side is expected to set the Process module.
