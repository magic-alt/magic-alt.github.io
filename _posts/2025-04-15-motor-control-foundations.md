---
title: 永磁同步电机控制与性能评估实战
date: 2025-04-15 09:30:00 +0800
tags: [电机控制, 控制理论, STM32]
excerpt: "从性能指标、参数辨识、FOC 实现到 PI 整定与排错的完整闭环；附 STM32 实操清单、调参流程与示例数据表。"
layout: post
comments: true
---
高性能驱动系统要同时兼顾效率、动态响应与稳定性，这篇文章集中整理了我在永磁同步电机（PMSM）项目中的经验，包括前期的性能参数评估、核心控制理论与实践落地要点。文章最后还附带了面向 STM32 控制器的工程建议。

* TOC
{:toc}

## 电机性能参数评估

系统设计从理解电机本体开始，以下指标决定了控制策略与硬件选型：

> **快速上手清单（拿来即测）**
>
> - 直流母线标定：万用表复核母线电压 ±1%  
> - 相电阻 $R_s$：四线法或交流法（1 kHz）测量，折算到工作温度  
> - $L_d/L_q$：开环注入法或频扫；无铁心饱和时应随电流近似线性  
> - 反电动势常数 $K_e$/永磁链 $\psi_f$：拖动法测定，记录线电压与机械转速  
> - 转动惯量 $J_m$：阶跃加速/自由减速识别  
> - 编码器极性与零位：锁轴给 $i_q>0$ 验方向；反向则交换两相电流或取负号  
> - 三相电流传感：一致性校准（零偏、量程、相序）

### 参数辨识与记录模板

| 参数 | 记号 | 典型值/单位 | 备注 |
|---|---|---|---|
| 定子相电阻 | $R_s$ | 0.2–1.5 Ω | 依据温度修正 $R_s(T)=R_{s0}[1+\alpha(T-T_0)]$ |
| d轴电感 | $L_d$ | 0.5–5 mH | 开环注入法辨识 |
| q轴电感 | $L_q$ | 0.5–5 mH | 表贴式电机 $L_d \approx L_q$ |
| 永磁链 | $\psi_f$ | 0.01–0.1 Wb | 拖动测反电动势：$E=\omega_e\psi_f$ |
| 极对数 | $p$ | 2–8 | 电角度 = 机械角度 × $p$ |
| 转子惯量 | $J_m$ | 10⁻⁴–10⁻² kg·m² | 影响速度环带宽 |

### 额定工况与扭矩-转速曲线

额定电压、额定电流与额定转速构成了安全运行的边界。扭矩与功率的关系可写成：

$$
P_{out} = T_e \cdot \omega_m
$$

其中 $T_e$ 为电磁转矩，$\omega_m$ 为机械角速度。通过实验测得不同转速下的扭矩，可绘制扭矩-转速曲线（T-n 曲线），判断弱磁区的可用范围。

### 效率与损耗模型

效率指标衡量输入与输出之间的能量损耗：

$$
\eta = \frac{P_{out}}{P_{in}} = \frac{T_e \cdot \omega_m}{3 U_{ph} I_{ph} \cos\varphi}
$$

电机损耗主要来自铜损、铁损与机械损。通过阶梯负载实验可以拟合损耗模型，后续在控制算法中实现在线效率优化。

### 热性能与温升

温升过程可用一阶热模型近似：

$$
T(t) = T_{amb} + \bigl(T_{ss} - T_{amb}\bigr) \bigl(1 - e^{-t/\tau}\bigr)
$$

其中 $T_{amb}$ 为环境温度，$T_{ss}$ 为稳态温度，$\tau$ 为热时间常数。通过热模型可以推导允许的过载时间，以及冷却设计的需求。

### 惯量与负载匹配

系统闭环带宽与电机-负载的等效惯量 $J_{eq}$ 密切相关：

$$
J_{eq} = J_m + J_L \cdot N^2
$$

$J_m$ 为电机转子惯量，$J_L$ 为负载惯量，$N$ 为传动比。惯量不匹配会导致调速困难或出现振荡，需要在机械设计阶段协同优化。

## 控制理论基础

### dq 轴数学模型

永磁同步电机的电压方程在 dq 旋转坐标系下可表示为：

$$
\begin{aligned}
 u_d &= R_s i_d + L_d \frac{di_d}{dt} - \omega_e L_q i_q, \\
 u_q &= R_s i_q + L_q \frac{di_q}{dt} + \omega_e \bigl(L_d i_d + \psi_f\bigr)
\end{aligned}
$$

其中 $R_s$ 为定子电阻，$L_d$、$L_q$ 为轴向电感，$\omega_e$ 为电角速度，$\psi_f$ 为永磁链。电磁转矩表达式为：

$$
T_e = \frac{3}{2} p \left[\psi_f i_q + (L_d - L_q) i_d i_q \right]
$$

当 $L_d \approx L_q$ 时，可设 $i_d = 0$ 以获得最大转矩每安培（MTPA）控制。

### Clarke 与 Park 变换

三相静止坐标系与旋转坐标系之间的变换关系分别为：

$$
\begin{bmatrix}
i_\alpha \\
i_\beta
\end{bmatrix}
=
\frac{2}{3}
\begin{bmatrix}
1 & -\tfrac{1}{2} & -\tfrac{1}{2} \\
0 & \tfrac{\sqrt{3}}{2} & -\tfrac{\sqrt{3}}{2}
\end{bmatrix}
\begin{bmatrix}
i_a \\
i_b \\
i_c
\end{bmatrix},
\qquad
\begin{bmatrix}
i_d \\
i_q
\end{bmatrix}
=
\begin{bmatrix}
\cos\theta_e & \sin\theta_e \\
-\sin\theta_e & \cos\theta_e
\end{bmatrix}
\begin{bmatrix}
i_\alpha \\
i_\beta
\end{bmatrix}.
$$

精准的转子位置 $\theta_e$ 是实现矢量控制的关键，可由霍尔传感器、旋变或基于反电动势的估算获得。

### 电流与速度闭环

对电流环采用 PI 控制器，结构如下：

$$
\begin{aligned}
 u_d &= k_{pd} (i_d^* - i_d) + k_{id} \int (i_d^* - i_d) \, dt, \\
 u_q &= k_{pq} (i_q^* - i_q) + k_{iq} \int (i_q^* - i_q) \, dt.
\end{aligned}
$$

速度环则根据负载特性选择带前馈的 PI 或 PI+速度前馈：

$$
\omega_m^* - \omega_m \xrightarrow{\text{PI}} T_e^*, \qquad i_q^* = \frac{2}{3} \frac{T_e^*}{p\,\psi_f}.
$$

在数字控制器中，离散化时需考虑采样周期 $T_s$，常用 Tustin 变换得到离散系数。

## 矢量控制实现步骤

1. **信号采集**：使用双通道 ADC 同步采样两相电流，计算第三相；速度可由编码器或无感算法估算。
2. **坐标变换**：执行 Clarke 与 Park 变换获得 $i_d$、$i_q$，并与给定值比较。
3. **电流调节**：PI 控制器输出 $u_d$、$u_q$，加入交叉耦合补偿项 $\omega_e L_q i_q$、$\omega_e L_d i_d$ 提升动态性能。
4. **电压限制**：根据直流母线电压 $U_{dc}$ 执行电压矢量限幅，避免超出逆变器能力。
5. **SVPWM 生成**：逆向 Park 变换得到 $u_\alpha$、$u_\beta$，通过空间矢量脉宽调制（SVPWM）计算开关时序：

   $$
   V_{ref} = \frac{2}{3} U_{dc} \sqrt{\left(\frac{T_1 - T_2}{T_s}\right)^2 + \left(\frac{T_0}{T_s}\right)^2 }
   $$

   其中 $T_1$、$T_2$ 为相邻有效矢量作用时间，$T_0$ 为零矢量时间，$T_s$ 为载波周期。

6. **弱磁控制（可选）**：在高速区通过设置负的 $i_d^*$ 降低反电动势，拓展最高转速。

## 基于 STM32 的实践要点

STM32 控制平台集成了高速 ADC、定时器、CORDIC 以及硬件除法器，适合实现高频率的 FOC 算法：

- **中断调度**：将电流环放在 PWM 同步触发的中断中执行，确保电流采样与更新的相位一致。
- **DMA 与缓存**：利用 DMA 将 ADC 数据搬运到内存，减少 CPU 开销；对调试信息可使用串口 DMA 循环缓冲。
- **参数管理**：为每个电机配置结构体，包含 $R_s$、$L_d$、$L_q$、$\psi_f$、采样周期等参数，并提供在线校准接口。
- **安全策略**：实现母线过压、过流、堵转检测与软关断流程，保障电机与驱动器安全。
- **工程注释**：在代码中对关键步骤（如坐标变换、限幅策略）编写详细注释，与说明文档保持同步，方便团队成员快速理解控制流程。

## 结语

电机控制工程是跨学科的系统工作：硬件要可靠、模型要准确、算法要稳定，还需要贴合具体的应用场景。希望这份笔记能够帮助你快速梳理 PMSM 控制的知识框架，并在 STM32 等嵌入式平台上构建出性能可靠的驱动系统。

---

## 电流/速度 PI 整定速查（离散域）

> 目标：**先电流环，后速度环**；以采样周期 $T_s$ 进行离散化，考虑电压限幅与反耦合项。

### 电流环（单轴等效）  
电机电流通道近似一阶：$G_p(s)=\frac{1}{L s + R}$。设目标带宽 $\omega_c = k \cdot \frac{R}{L}$（常取 $k\in[3,7]$）。

PI 连续参数：  
$$
K_p = L \,\omega_c,\qquad K_i = R \,\omega_c
$$

Tustin 离散化：  
$$
u[k] = u[k-1] + K_p(e[k]-e[k-1]) + K_i \frac{T_s}{2}(e[k]+e[k-1])
$$

记得加入**交叉耦合补偿**：  
$$u_d \leftarrow u_d + \omega_e L_q i_q,\quad u_q \leftarrow u_q - \omega_e L_d i_d$$

### 速度环  
惯量近似：$G_\omega(s)=\frac{K_t}{J s}$，设带宽为电流环的 $1/10\sim1/5$。  
PI（含前馈）：  
$$
T_e^* = K_{p\omega} e_\omega + K_{i\omega} \int e_\omega \, dt + B \omega^* + J \dot{\omega}^*
$$

其中 $B$ 为粘性阻尼估计，$J\dot{\omega}^*$ 为加速前馈（可选）。

---

## 常见故障与排查流程

| 故障现象 | 可能原因 | 排查方法 |
|---|---|---|
| 起转抖动/啸叫 | 电角度极性错误或零位偏移 | 反向电角度，重标定零位 |
| 低速力矩不足 | $R_s$ 估计偏差、电流采样延迟 | 复核 $R_s$，用 PWM 同步采样 |
| 高速失步 | 弱磁过浅/过深、母线过压限制 | 动态调节 $i_d^*<0$，引入电压限幅与扭矩限幅 |
| 温升过快 | 铜损/铁损模型失配 | 在线估计 $\hat{R}_s(T)$，限制最大 $i_q$ 与占空比 |
| SVPWM 失真 | 死区补偿不足 | 基于采样反推补偿量，或切换到 SVM+空间电压矢量补偿 |

---

## STM32 实操打包清单（可粘到 README）

**硬件配置**
- **TIM1/8**：中心对称 PWM，触发 ADC 采样；注入中断运行电流环  
- **ADC**：双通道并行采样 $i_a,i_b$；DMA 环形缓冲；采样点在 PWM 中点  
- **FOC 周期**：10–50 kHz；速度环：1–2 kHz  
- **CORDIC/库**：用于 sin/cos（Park/反 Park 变换）  

**保护策略**
- 过流比较器（硬件即时关断）+ 软件软停（斜坡下电）  
- 母线过压/欠压检测  
- 堵转检测（速度反馈与给定长时间不一致）  
- 温度监控（ADC 采样功率管/电机温度）

**调试工具**
- 串口/RTT 实时打点：$i_d$、$i_q$、$\omega$、$T_e$  
- 示波器：三相电流波形、母线电压、PWM 占空比  
- 变量监控：HAL 断点或 ST-Link Utility 在线调参

**代码组织建议**
```c
typedef struct {
    float Rs, Ld, Lq, psi_f;  // 电机参数
    float Ts;                  // 采样周期
    float Kp_id, Ki_id;        // d轴电流 PI
    float Kp_iq, Ki_iq;        // q轴电流 PI
    float Kp_w, Ki_w;          // 速度 PI
} MotorParams_t;

void FOC_CurrentLoop(void);    // 电流环（高频中断）
void FOC_SpeedLoop(void);      // 速度环（低频调用）
void FOC_SVM(float ud, float uq, float theta);  // SVPWM
```
