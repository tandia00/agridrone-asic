// SPDX-FileCopyrightText: 2024 AgriDrone Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

// AgriDrone ASIC – GPIO Mode Definitions for Caravel user_project_wrapper
//
// GPIO mapping (Caravel pads 5-37):
//   GPIO  5- 7 : unused              → management input no-pull
//   GPIO  8    : SPI SCLK            → user input no-pull
//   GPIO  9    : SPI MOSI            → user input no-pull
//   GPIO 10    : SPI MISO            → user output
//   GPIO 11    : SPI CSn             → user input no-pull
//   GPIO 12-19 : PWM out[0:7]        → user output (8 channels)
//   GPIO 20    : Spray PWM           → user output
//   GPIO 21    : Flow pulse          → user input no-pull
//   GPIO 22    : Kill-switch n       → user output
//   GPIO 23    : Armed LED           → user output
//   GPIO 24    : Watchdog trip LED   → user output
//   GPIO 25-37 : unused              → management input no-pull

// ── Unused / reserved (management control) ───────────────────────────────
`define USER_CONFIG_GPIO_5_INIT  `GPIO_MODE_MGMT_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_6_INIT  `GPIO_MODE_MGMT_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_7_INIT  `GPIO_MODE_MGMT_STD_INPUT_NOPULL

// ── SPI peripheral interface ──────────────────────────────────────────────
`define USER_CONFIG_GPIO_8_INIT  `GPIO_MODE_USER_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_9_INIT  `GPIO_MODE_USER_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_10_INIT `GPIO_MODE_USER_STD_OUTPUT
`define USER_CONFIG_GPIO_11_INIT `GPIO_MODE_USER_STD_INPUT_NOPULL

// ── PWM motor outputs (8 channels) ───────────────────────────────────────
`define USER_CONFIG_GPIO_12_INIT `GPIO_MODE_USER_STD_OUTPUT
`define USER_CONFIG_GPIO_13_INIT `GPIO_MODE_USER_STD_OUTPUT
`define USER_CONFIG_GPIO_14_INIT `GPIO_MODE_USER_STD_OUTPUT
`define USER_CONFIG_GPIO_15_INIT `GPIO_MODE_USER_STD_OUTPUT
`define USER_CONFIG_GPIO_16_INIT `GPIO_MODE_USER_STD_OUTPUT
`define USER_CONFIG_GPIO_17_INIT `GPIO_MODE_USER_STD_OUTPUT
`define USER_CONFIG_GPIO_18_INIT `GPIO_MODE_USER_STD_OUTPUT
`define USER_CONFIG_GPIO_19_INIT `GPIO_MODE_USER_STD_OUTPUT

// ── Spray controller ─────────────────────────────────────────────────────
`define USER_CONFIG_GPIO_20_INIT `GPIO_MODE_USER_STD_OUTPUT
`define USER_CONFIG_GPIO_21_INIT `GPIO_MODE_USER_STD_INPUT_NOPULL

// ── Safety outputs ────────────────────────────────────────────────────────
`define USER_CONFIG_GPIO_22_INIT `GPIO_MODE_USER_STD_OUTPUT
`define USER_CONFIG_GPIO_23_INIT `GPIO_MODE_USER_STD_OUTPUT
`define USER_CONFIG_GPIO_24_INIT `GPIO_MODE_USER_STD_OUTPUT

// ── Unused (management control) ───────────────────────────────────────────
`define USER_CONFIG_GPIO_25_INIT `GPIO_MODE_MGMT_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_26_INIT `GPIO_MODE_MGMT_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_27_INIT `GPIO_MODE_MGMT_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_28_INIT `GPIO_MODE_MGMT_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_29_INIT `GPIO_MODE_MGMT_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_30_INIT `GPIO_MODE_MGMT_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_31_INIT `GPIO_MODE_MGMT_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_32_INIT `GPIO_MODE_MGMT_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_33_INIT `GPIO_MODE_MGMT_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_34_INIT `GPIO_MODE_MGMT_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_35_INIT `GPIO_MODE_MGMT_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_36_INIT `GPIO_MODE_MGMT_STD_INPUT_NOPULL
`define USER_CONFIG_GPIO_37_INIT `GPIO_MODE_MGMT_STD_INPUT_NOPULL
