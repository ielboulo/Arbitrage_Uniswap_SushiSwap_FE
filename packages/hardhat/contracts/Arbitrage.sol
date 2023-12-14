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
    address constant WETH_ADDRESS    =0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6; // not used here 
    address constant ETH_ADDRESS     =0x2170Ed0880ac9A755fd29B2688956BD959F933F8; // Mainnet
    address constant SEP_ETH_ADDRESS =0x99FCee8A75550a027Fdb674c96F2D7DA31C79fcD; // ETH on Sepolia
    address constant SEP_WETH_ADDRESS =0xb16F35c0Ae2912430DAc15764477E179D9B9EbEa; // WETH on Sepolia

    address constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;   
    address constant SUSHISWAP_ROUTER_ADDRESS = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

    IUniswapV2Router private uniswapRouter;
    ISushiSwapRouter private sushiswapRouter;
    address private owner; 

    event FetchBalance(uint256 amount);
    event ArbitrageSuccessful(uint256 amount);
    event RecoverySuccessful();


    constructor() {
        uniswapRouter = IUniswapV2Router(UNISWAP_ROUTER_ADDRESS);
        sushiswapRouter = ISushiSwapRouter(SUSHISWAP_ROUTER_ADDRESS);
        owner = msg.sender;
    }

    function getUniswapRouter() pure public returns (address) {
        return UNISWAP_ROUTER_ADDRESS; 
    }
    function getSushiswapRouter() pure public returns (address) {
        return SUSHISWAP_ROUTER_ADDRESS; 
    }

    function swap_WETH(address _address,uint256 _amountIn) external payable {
        IERC20(SEP_WETH_ADDRESS).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(SEP_WETH_ADDRESS).approve(address(UNISWAP_ROUTER_ADDRESS) ,_amountIn); 
        // Buy the token on Uniswap with ETH
        address[] memory path = new address[](2);
        path[0] = SEP_WETH_ADDRESS;
        path[1] = _address;
        // Get the amount of tokens received
        uint256[] memory amounts = uniswapRouter.swapExactTokensForTokens(_amountIn, 0, path, address(this), block.timestamp);
        uint256 amountOut = amounts[1];
        // Sell the token on Sushiswap with _address
        IERC20(_address).approve(address(SUSHISWAP_ROUTER_ADDRESS) ,amountOut); 
        path[0] = _address;
        path[1] = SEP_WETH_ADDRESS;
        uint256[] memory amounts_1 = sushiswapRouter.swapExactTokensForTokens(amountOut,0, path, msg.sender, block.timestamp);
        uint256 amountOut_1 = amounts_1[1];
        require(amountOut_1 > _amountIn , "Arbitrage fail !");
        
    }

    function swap_Sepolia_Eth_pay(address _address, uint256 _amountIn) external payable {
        require(msg.value >= _amountIn, "Insufficient funds sent with the transaction");

        // Buy the token on Uniswap with ETH
        address[] memory path = new address[](2);
        path[0] = SEP_ETH_ADDRESS; // ETH address
        path[1] = _address;

        uint256[] memory amounts = uniswapRouter.swapExactETHForTokens{value: _amountIn}(0, path, address(this), block.timestamp);
        uint256 amountOut = amounts[1];

        // Sell the token on Sushiswap for ETH
        path[0] = _address;
        path[1] = SEP_ETH_ADDRESS; // ETH address

        uint256[] memory amounts_1 = sushiswapRouter.swapExactTokensForETH(amountOut, 0, path, msg.sender, block.timestamp);
        uint256 amountOut_1 = amounts_1[1];

        require(amountOut_1 > _amountIn, "Arbitrage fail!");
        emit ArbitrageSuccessful(amountOut_1 - _amountIn);
    }


    function getPriceFromUniswap(address _tokenAddress, uint256 _amountIn) external view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = SEP_ETH_ADDRESS;
        path[1] = _tokenAddress;
        
        uint256[] memory amounts = uniswapRouter.getAmountsOut(_amountIn, path);
        
        // The last element in the 'amounts' array is the desired output amount
        return amounts[1];
    }

    function getPriceFromSushiswap(address _tokenAddress, uint256 _amountIn) external view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = SEP_ETH_ADDRESS;
        path[1] = _tokenAddress;
        
        uint256[] memory amounts = sushiswapRouter.getAmountsOut(_amountIn, path);
        
        // The last element in the 'amounts' array is the desired output amount
        return amounts[1];
    }

	function recoverEth() external {
        require(msg.sender == owner," not owner !"  ); 
		payable(msg.sender).transfer(address(this).balance);
        emit RecoverySuccessful();
	}

    // Function to get the balance of the smart contract in terms of ETH
    function getBalanceInEth() external view returns (uint256) {
        return address(this).balance;
    }
    // Function to get the balance of the smart contract in terms of a specific token
    function getTokenBalanceContract(address tokenAddress) external view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }
    // Function to get the balance of a wallet for a specific token
    function getTokenBalance(address tokenAddress) external view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(msg.sender);
    }

	receive() external payable {}
}