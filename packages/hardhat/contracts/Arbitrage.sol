// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IUniswapV2Router {
    function swapExactTokensForETH(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut,address[] calldata path,address to,uint deadline) external payable returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin,address[] calldata path,address to,uint deadline) external payable returns (uint[] memory amounts);
}

interface ISushiSwapRouter {
    function swapExactETHForTokens(uint amountOutMin,address[] calldata path,address to,uint deadline) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

interface IERC20 {
	function totalSupply() external view returns (uint);
	function balanceOf(address account) external view returns (uint);
	function transfer(address recipient, uint amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint);
	function approve(address spender, uint amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
}

contract Arbitrage {
    address constant WETH_ADDRESS    =0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address constant ETH_ADDRESS     =0x2170Ed0880ac9A755fd29B2688956BD959F933F8; // Mainnet
    address constant SEP_ETH_ADDRESS =0x99FCee8A75550a027Fdb674c96F2D7DA31C79fcD; // Sepolia

    address constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; //  On Goerli Mainnet 
    address constant SUSHISWAP_ROUTER_ADDRESS = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506; // On Goerli Mainnet

    IUniswapV2Router private uniswapRouter;
    ISushiSwapRouter private sushiswapRouter;

    string private text;


    event FetchBalance(uint256 amount);

    constructor() {
        uniswapRouter = IUniswapV2Router(UNISWAP_ROUTER_ADDRESS);
        sushiswapRouter = ISushiSwapRouter(SUSHISWAP_ROUTER_ADDRESS);
    }

    function getUniswapRouter() external view returns (address) {
        return UNISWAP_ROUTER_ADDRESS; 
    }
    function getSushiswapRouter() external view returns (address) {
        return SUSHISWAP_ROUTER_ADDRESS; 
    }

    function swap_WETH(address _address,uint256 _amountIn) external {
        IERC20(WETH_ADDRESS).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(WETH_ADDRESS).approve(address(UNISWAP_ROUTER_ADDRESS) ,_amountIn); 
        // Buy the token on Uniswap with ETH
        address[] memory path = new address[](2);
        path[0] = WETH_ADDRESS;
        path[1] = _address;
        // Get the amount of tokens received
        uint256[] memory amounts = uniswapRouter.swapExactTokensForTokens(_amountIn, 0, path, address(this), block.timestamp);
        uint256 amountOut = amounts[1];
        // Sell the token on Sushiswap with _address
        IERC20(_address).approve(address(SUSHISWAP_ROUTER_ADDRESS) ,amountOut); 
        path[0] = _address;
        path[1] = WETH_ADDRESS;
        uint256[] memory amounts_1 = sushiswapRouter.swapExactTokensForTokens(amountOut,0, path, msg.sender, block.timestamp);
        uint256 amountOut_1 = amounts_1[1];
        require(amountOut_1 > _amountIn , "Arbitrage fail !");
        
    }


    function setText(string memory newText) public {
        text = newText;
    }


function swap_Eth_pay(address _address, uint256 _amountIn) external payable {
    require(msg.value >= _amountIn, "Insufficient funds sent with the transaction");

    // Rest of your existing code...

    // Buy the token on Uniswap with ETH
    address[] memory path = new address[](2);
    path[0] = SEP_ETH_ADDRESS; // ETH address
    path[1] = _address;

    uint256[] memory amounts = uniswapRouter.swapExactETHForTokens{value: _amountIn}(0, path, address(this), block.timestamp);
    uint256 amountOut = amounts[1];

    // Log amounts for debugging
    emit FetchBalance(amountOut);

    // Sell the token on Sushiswap for ETH
    path[0] = _address;
    path[1] = SEP_ETH_ADDRESS; // ETH address

    uint256[] memory amounts_1 = sushiswapRouter.swapExactTokensForETH(amountOut, 0, path, msg.sender, block.timestamp);
    uint256 amountOut_1 = amounts_1[1];

    require(amountOut_1 > _amountIn, "Arbitrage fail!");
}


    function getPriceFromUniswap(address _tokenAddress, uint256 _amountIn) external view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = WETH_ADDRESS;
        path[1] = _tokenAddress;
        
        uint256[] memory amounts = uniswapRouter.getAmountsOut(_amountIn, path);
        
        // The last element in the 'amounts' array is the desired output amount
        return amounts[1];
    }

    function getPriceFromSushiswap(address _tokenAddress, uint256 _amountIn) external view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = WETH_ADDRESS;
        path[1] = _tokenAddress;
        
        uint256[] memory amounts = uniswapRouter.getAmountsOut(_amountIn, path);
        
        // The last element in the 'amounts' array is the desired output amount
        return amounts[1];
    }


	receive() external payable {}
}